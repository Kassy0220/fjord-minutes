# frozen_string_literal: true

class MeetingSecretary
  def self.prepare_for_meeting
    Course.find_each do |course|
      secretary = new(course)
      secretary.create_minute
    end
  end

  def initialize(course)
    @course = course
  end

  def create_minute
    latest_minute = @course.minutes.order(:created_at).last
    unless latest_minute.already_finished?
      leave_log("create_minute, #{@course.name}, not_executed, latest meeting isn't finished.")
      return
    end

    meeting_date = latest_minute.next_meeting_date
    next_meeting_date = MeetingDateCalculator.next_meeting_date(meeting_date, @course.meeting_week)

    @course.minutes.create!(meeting_date:, next_meeting_date:)
    leave_log("create_minute, #{@course.name}, executed")
  end

  private

  def leave_log(message)
    Rails.logger.info(message)
  end
end
