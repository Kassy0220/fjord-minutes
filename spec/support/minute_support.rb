# frozen_string_literal: true

module MinuteSupport
  def create_minutes(course: nil, first_meeting_date: nil, count: nil)
    FactoryBot.create(:minute, meeting_date: first_meeting_date, next_meeting_date: MeetingDateCalculator.next_meeting_date(first_meeting_date, course.meeting_week), course:)
    FactoryBot.build_list(:minute, count - 1) do |minute|
      minute.meeting_date = course.minutes.last.next_meeting_date
      minute.next_meeting_date = MeetingDateCalculator.next_meeting_date(course.minutes.last.next_meeting_date, course.meeting_week)
      minute.course = course
      minute.save!
    end
  end
end

RSpec.configure do |config|
  config.include MinuteSupport
end
