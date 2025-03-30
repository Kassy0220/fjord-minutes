# frozen_string_literal: true

class MinuteGithubExporter
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze

  def self.export_to_github_wiki(minute)
    new(minute.course).commit_and_push(minute)
  end

  attr_reader :working_directory

  def initialize(course)
    @course = course
    @working_directory = rails_course? ? CLONED_BOOTCAMP_WIKI_PATH : CLONED_AGENT_WIKI_PATH
    # インストールアクセストークンを更新するため、ワーキングディレクトリが残っていれば削除する
    FileUtils.rm_r(@working_directory) if File.exist?(@working_directory)
    @git = Git.clone(wiki_repository_url, @working_directory, log: Logger.new($stdout))
  end

  def commit_and_push(minute)
    @git.pull
    set_github_account
    commit_minute_markdown(minute)
    @git.push('origin', 'master') # GitHub Wiki のデフォルトブランチはmaster
  end

  private

  def wiki_repository_url
    token = create_install_access_token
    wiki_url = rails_course? ? ENV.fetch('BOOTCAMP_WIKI_URL', nil) : ENV.fetch('AGENT_WIKI_URL', nil)
    wiki_url.sub(%r{(https://)(github\.com.+)}, "\\1x-access-token:#{token}@\\2")
  end

  def create_install_access_token
    private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.github_app_private_key)
    payload = {
      iat: Time.now.to_i - 60,
      exp: Time.now.to_i + (10 * 60),
      iss: ENV.fetch('GITHUB_APP_ID', nil)
    }
    jwt = JWT.encode(payload, private_key, 'RS256')

    response = Net::HTTP.post(
      URI("https://api.github.com/app/installations/#{ENV.fetch('GITHUB_APP_INSTALLATIONS_ID', nil)}/access_tokens"),
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

  def set_github_account
    @git.config('user.name', ENV.fetch('GITHUB_USER_NAME', nil))
    @git.config('user.email', ENV.fetch('GITHUB_USER_EMAIL', nil))
  end

  def commit_minute_markdown(minute)
    filename = "#{minute.title}.md"
    File.write(File.join(@working_directory, filename), MarkdownBuilder.build(minute))

    @git.add(filename)
    @git.commit("#{filename} committed")
  end

  def rails_course?
    @course.name == 'Railsエンジニアコース'
  end
end
