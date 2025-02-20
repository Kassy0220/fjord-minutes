# frozen_string_literal: true

class MarkdownBuilder
  TEMPLATE_PATH = 'config/templates/minute.md'

  def self.build(minute)
    new(minute).build
  end

  def initialize(minute)
    @minute = minute
  end

  def build
    template = File.read(TEMPLATE_PATH)
    minute_data = {
      minute: @minute,
      afternoon_attendees:,
      night_attendees:,
      absentees:,
      topics:,
      next_date:
    }
    ERB.new(template).result_with_hash(minute_data)
  end

  private

  def afternoon_attendees
    @minute.attendances.at_afternoon_session.with_members
           .order(:member_id)
           .pluck(:name)
           .map { |name| "- #{member_link(name)}" }
           .join("\n")
  end

  def night_attendees
    @minute.attendances.at_night_session.with_members
           .order(:member_id)
           .pluck(:name)
           .map { |name| "- #{member_link(name)}" }
           .join("\n")
  end

  def absentees
    @minute.attendances.absent.with_members
           .order(:member_id)
           .pluck(:absence_reason, :progress_report, :name)
           .map { |absence_reason, progress_report, name| "- #{member_link(name)}\n  - 欠席理由\n    - #{absence_reason}\n  - 進捗報告\n#{split_line_to_list(progress_report)}" }
           .join("\n")
  end

  def split_line_to_list(progress_report)
    progress_report.split("\r\n").map { |report| "    - #{rewrite_issue_number_as_link(report)}" }.join("\n")
  end

  def rewrite_issue_number_as_link(progress_report)
    progress_report.gsub(/#(\d+)/, "[#\\1](#{@minute.course.repository_url}/issues/\\1)")
  end

  def member_link(name)
    "[@#{name}](https://github.com/#{name})"
  end

  def topics
    @minute.topics.order(:created_at)
           .preload(:topicable)
           .map { |topic| "- #{topic.content}(#{topic.topicable.name})" }
           .join("\n")
  end

  def next_date
    meeting_date = I18n.l(@minute.next_meeting_date, format: :long)
    return "- #{meeting_date}" unless HolidayJp.holiday?(@minute.next_meeting_date)

    holiday_name = HolidayJp.between(@minute.next_meeting_date, @minute.next_meeting_date).first.name
    <<~DATE.chomp
      - #{meeting_date}
        - 次回開催日は#{holiday_name}です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
    DATE
  end
end
