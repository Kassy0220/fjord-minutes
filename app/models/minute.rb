# frozen_string_literal: true

class Minute < ApplicationRecord
  TEMPLATE_PATH = 'config/templates/minute.md'

  belongs_to :course
  has_many :topics, dependent: :destroy
  has_many :attendances, dependent: :destroy

  def already_finished?
    meeting_date.before?(Time.zone.today)
  end

  def title
    "ふりかえり・計画ミーティング#{I18n.l(meeting_date)}"
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
    ERB.new(File.read(TEMPLATE_PATH)).result_with_hash(minute_data)
  end

  private

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
    meeting_date = I18n.l(next_meeting_date, format: :long)
    return "- #{meeting_date}" unless HolidayJp.holiday?(next_meeting_date)

    holiday_name = HolidayJp.between(next_meeting_date, next_meeting_date).first.name
    <<~DATE.chomp
      - #{meeting_date}
        - 次回開催日は#{holiday_name}です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
    DATE
  end
end
