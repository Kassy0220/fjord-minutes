# frozen_string_literal: true

class Minute < ApplicationRecord
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze
  DEFAULT_BRANCH_FOR_GITHUB_WIKI = 'master'
  CLOCK_DRIFT_BUFFER_SEC = 60
  TOKEN_EXPIRATION_TIME_SEC = 600
  MARKDOWN_TEMPLATE = 'config/templates/minute.md'

  belongs_to :meeting
  has_many :topics, dependent: :destroy
  has_many :attendances, through: :meeting
  has_one :course, through: :meeting

  def title
    "ふりかえり・計画ミーティング#{I18n.l(meeting.date)}"
  end

  def export_to_github_wiki
    working_directory = rails_course? ? CLONED_BOOTCAMP_WIKI_PATH : CLONED_AGENT_WIKI_PATH
    # インストールアクセストークンを更新するため、ワーキングディレクトリが残っていれば削除する
    FileUtils.rm_r(working_directory) if File.exist?(working_directory)
    git = Git.clone(wiki_repository_url, working_directory, log: Logger.new($stdout))
    git.config('user.name', ENV.fetch('GITHUB_USER_NAME'))
    git.config('user.email', ENV.fetch('GITHUB_USER_EMAIL'))

    filename = "#{title}.md"
    filepath = File.join(working_directory, filename)
    # Minute#titleにユーザーの入力値が含まれるようになった場合、ディレクトリトラバーサルが発生する危険性がある
    # 現時点でのMinute#titleの実装では問題が発生しないが、念の為ファイル名の確認を行っておく
    raise "Error!, Invalid file name: #{filename}" unless File.dirname(filepath) == working_directory.to_s

    File.write(filepath, to_markdown)
    git.add(filename)
    git.commit("#{filename} committed")
    git.push('origin', DEFAULT_BRANCH_FOR_GITHUB_WIKI)
  end

  def to_markdown
    minute_data = {
      afternoon_attendees:,
      night_attendees:,
      absentees:,
      release_branch:,
      release_note:,
      discussed_topics:,
      other:,
      next_date:
    }
    ERB.new(File.read(MARKDOWN_TEMPLATE)).result_with_hash(minute_data)
  end

  private

  def wiki_repository_url
    token = create_install_access_token
    course.wiki_repository_url.sub(%r{(?<=^https://)}, "x-access-token:#{token}@")
  end

  def create_install_access_token
    private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.github_app_private_key)
    payload = {
      iat: Time.now.to_i - CLOCK_DRIFT_BUFFER_SEC,
      exp: Time.now.to_i + TOKEN_EXPIRATION_TIME_SEC,
      iss: ENV.fetch('GITHUB_APP_ID')
    }
    jwt = JWT.encode(payload, private_key, 'RS256')

    response = Net::HTTP.post(
      URI("https://api.github.com/app/installations/#{ENV.fetch('GITHUB_APP_INSTALLATIONS_ID')}/access_tokens"),
      nil,
      {
        Accept: 'application/vnd.github+json',
        Authorization: "Bearer #{jwt}",
        'X-GitHub-Api-Version' => '2022-11-28'
      }
    )

    raise "Error!, fail to create install access token. Message : #{response.code}, #{response.message}" unless response.code == '201'

    JSON.parse(response.body)['token']
  end

  def rails_course?
    course.kind == 'back_end'
  end

  def afternoon_attendees
    attendances.at_afternoon_session.with_members
               .order(:member_id)
               .pluck(:name)
               .map { |name| "- #{github_account_link(name)}" }
               .join("\n")
  end

  def night_attendees
    attendances.at_night_session.with_members
               .order(:member_id)
               .pluck(:name)
               .map { |name| "- #{github_account_link(name)}" }
               .join("\n")
  end

  def absentees
    attendances.absent.with_members
               .order(:member_id)
               .pluck(:absence_reason, :progress_report, :name)
               .map { |absence_reason, progress_report, name| "- #{github_account_link(name)}\n  - 欠席理由\n    - #{absence_reason}\n  - 進捗報告\n#{split_line_to_list(progress_report)}" }
               .join("\n")
  end

  def split_line_to_list(progress_report)
    progress_report.split("\r\n").map { |report| "    - #{rewrite_issue_number_as_link(report)}" }.join("\n")
  end

  def rewrite_issue_number_as_link(progress_report)
    progress_report.gsub(/#(\d+)/, "[#\\1](#{course.repository_url}/issues/\\1)")
  end

  def github_account_link(name)
    "[@#{name}](https://github.com/#{name})"
  end

  def discussed_topics
    topics.order(:created_at)
          .preload(:topicable)
          .map { |topic| "- #{topic.content}(#{topic.topicable.name})" }
          .join("\n")
  end

  def next_date
    formatted_date = I18n.l(meeting.next_date, format: :long)
    return "- #{formatted_date}" unless HolidayJp.holiday?(meeting.next_date)

    holiday_name = HolidayJp.between(meeting.next_date, meeting.next_date).first.name
    <<~DATE.chomp
      - #{formatted_date}
        - 次回開催日は#{holiday_name}です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
    DATE
  end
end
