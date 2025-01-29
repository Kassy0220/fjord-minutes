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
      day_attendees:,
      night_attendees:,
      absentees:,
      topics:,
      next_date:
    }
    ERB.new(template).result_with_hash(minute_data)
  end

  private

  def day_attendees
    @minute.attendances.where(time: :day)
           .includes(:member)
           .order(:member_id)
           .pluck(:name)
           .map { |name| "- #{name}" }
           .join("\n")
  end

  def night_attendees
    @minute.attendances.where(time: :night)
           .includes(:member)
           .order(:member_id)
           .pluck(:name)
           .map { |name| "- #{name}" }
           .join("\n")
  end

  def absentees
    @minute.attendances.where(status: :absent)
           .includes(:member)
           .order(:member_id)
           .pluck(:absence_reason, :progress_report, :name)
           .map { |absence_reason, progress_report, name| "- #{name}\n  - 欠席理由\n    - #{absence_reason}\n  - 進捗報告\n#{split_line_to_list(progress_report)}" }
           .join("\n")
  end

  def split_line_to_list(progress_report)
    progress_report.split("\r\n").map { |report| "    - #{report}" }.join("\n")
  end

  def topics
    @minute.topics.order(:created_at)
           .preload(:topicable)
           .map { |topic| "- #{topic.content}(#{topic.topicable.name})" }
           .join("\n")
  end

  def next_date
    day_of_the_week = %w[日 月 火 水 木 金 土][@minute.next_meeting_date.wday]
    meeting_date = "#{@minute.next_meeting_date.strftime('%Y年%m月%d日')}(#{day_of_the_week})"
    return "- #{meeting_date}" unless HolidayJp.holiday?(@minute.next_meeting_date)

    holiday_name = HolidayJp.between(@minute.next_meeting_date, @minute.next_meeting_date).first.name
    <<~DATE.chomp
      - #{meeting_date}
        - 次回開催日は#{holiday_name}です。もしミーティングをお休みにする場合は、開催日を変更しましょう。
    DATE
  end
end
