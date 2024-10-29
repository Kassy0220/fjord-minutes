# frozen_string_literal: true

class MeetingDateCalculator
  DAY_OF_THE_WEEK_FOR_MEETING = { sun: 0, mon: 1, tue: 2, wed: 3, thu: 4, fri: 5, sat: 6 }[:wed]

  def self.next_meeting_date(date, meeting_week)
    new(date, meeting_week).next_meeting_date
  end

  def initialize(date, meeting_week)
    @date = date
    @meeting_week = meeting_week
  end

  def next_meeting_date
    @date.day <= 14 ? @date + 2.weeks : next_month_meeting_date
  end

  private

  def next_month_meeting_date
    year = @date.month <= 11 ? @date.year : @date.year + 1
    next_month = @date.month <= 11 ? @date.month + 1 : 1

    meeting_days = all_meeting_days_in_month(year, next_month)
    @meeting_week == 'odd' ? Time.zone.local(year, next_month, meeting_days.first) : Time.zone.local(year, next_month, meeting_days.second)
  end

  def all_meeting_days_in_month(year, month)
    meeting_days = []

    first_day = Date.new(year, month, 1)
    last_day = first_day.end_of_month

    meeting_day = first_day
    meeting_day += 1 until meeting_day.wday == DAY_OF_THE_WEEK_FOR_MEETING

    while meeting_day <= last_day
      meeting_days << meeting_day.day
      meeting_day += 7
    end

    meeting_days
  end
end
