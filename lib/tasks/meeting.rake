# frozen_string_literal: true

namespace :meeting do
  desc 'Create minute and notify today meeting'
  task prepare_for_meeting: :environment do
    Course.find_each do |course|
      course.create_next_meeting_and_minute

      if course.minutes.none?
        Rails.logger.info("notify_meeting_day, #{course.name}, not_executed, There are no minutes yet.")
        next
      end

      latest_meeting = course.meetings.order(:date).last
      unless latest_meeting.date == Time.zone.today
        Rails.logger.info("notify_meeting_day, #{course.name}, not_executed, Today is not meeting day.")
        next
      end

      if latest_meeting.notified_at
        Rails.logger.info("notify_meeting_day, #{course.name}, not_executed, Notification was already sent.")
        next
      end

      latest_meeting.notify_meeting_day
    end
  end
end
