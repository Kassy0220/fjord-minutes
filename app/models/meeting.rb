# frozen_string_literal: true

class Meeting < ApplicationRecord
  include Rails.application.routes.url_helpers

  DAY_OF_THE_WEEK_FOR_MEETING = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }[:wed]
  TEMPLATE_FOR_TODAY_MEETING = 'config/templates/today_meeting_message.md'

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

  private

  def set_next_date
    self.next_date = date.day <= 14 ? date + 2.weeks : next_month_meeting_date
  end

  def next_month_meeting_date
    year = date.next_month.year
    next_month = date.next_month.month

    meeting_days = all_meeting_days_in_month(year, next_month)
    course.meeting_week == 'odd' ? Time.zone.local(year, next_month, meeting_days.first) : Time.zone.local(year, next_month, meeting_days.second)
  end

  def all_meeting_days_in_month(year, month)
    meeting_days = []

    first_day = Time.zone.local(year, month, 1)
    last_day = first_day.end_of_month

    meeting_day = first_day
    meeting_day += 1.day until meeting_day.wday == DAY_OF_THE_WEEK_FOR_MEETING

    while meeting_day <= last_day
      meeting_days << meeting_day.day
      meeting_day += 7.days
    end

    meeting_days
  end
end
