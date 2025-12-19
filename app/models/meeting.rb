# frozen_string_literal: true

class Meeting < ApplicationRecord
  include Rails.application.routes.url_helpers

  DAY_OF_THE_WEEK_FOR_MEETING = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }[:wed]
  TEMPLATE_FOR_TODAY_MEETING = 'config/templates/today_meeting_message.md'
  SCHEDULED_DATES_PERIOD = 3.months

  before_create :set_next_date

  belongs_to :course
  has_one :minute, dependent: :destroy
  has_many :attendances, dependent: :destroy

  def already_finished?
    date.before?(Time.zone.today)
  end

  def notify_meeting_day
    notification_message = ERB.new(File.read(TEMPLATE_FOR_TODAY_MEETING))
                              .result_with_hash({ discord_role_id: course.discord_role_id, course_name: course.name, url: new_meeting_attendance_url(self) })
    Discord::Notifier.message(notification_message, url: course.discord_webhook_url)
    Rails.logger.info("notify_today_meeting, #{course.name}, executed")
    update!(notified_at: Time.zone.now)
  end

  def scheduled_dates(limit: 1)
    (date.next_day..date + SCHEDULED_DATES_PERIOD).select { |date| meeting_day?(date) }.shift(limit)
  end

  private

  def set_next_date
    # 53週 → 1週のように、cweekの偶奇が年を跨いでも変わらない場合に対応
    next_meeting_date =
      if date.cweek == 52 && (date + 1.week).cweek == 53
        date + 3.weeks
      elsif date.cweek == 53
        date + 1.week
      else
        date + 2.weeks
      end

    self.next_date = next_meeting_date
  end

  def meeting_day?(date)
    if course.meeting_week == 'odd'
      date.cweek.odd? && date.wday == DAY_OF_THE_WEEK_FOR_MEETING
    else
      date.cweek.even? && date.wday == DAY_OF_THE_WEEK_FOR_MEETING
    end
  end
end
