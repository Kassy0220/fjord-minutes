# frozen_string_literal: true

module MeetingSupport
  def create_meetings(course: nil, first_meeting_date: nil, count: nil)
    FactoryBot.create(:meeting, date: first_meeting_date, next_date: MeetingDateCalculator.next_meeting_date(first_meeting_date, course.meeting_week), course:)
    FactoryBot.build_list(:meeting, count - 1) do |meeting|
      meeting.date = course.meetings.last.next_date
      meeting.next_date = MeetingDateCalculator.next_meeting_date(course.meetings.last.next_date, course.meeting_week)
      meeting.course = course
      meeting.save!
    end
  end
end

RSpec.configure do |config|
  config.include MeetingSupport
end
