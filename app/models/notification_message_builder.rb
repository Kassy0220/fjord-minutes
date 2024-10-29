# frozen_string_literal: true

class NotificationMessageBuilder
  include Rails.application.routes.url_helpers
  TEMPLATE_PATH_FOR_MINUTE_CREATION = 'config/templates/minute_creation_message.md'

  def self.build(course, minute)
    new.build(course, minute)
  end

  def initialize
    @template = File.read(TEMPLATE_PATH_FOR_MINUTE_CREATION)
  end

  def build(course, minute)
    ERB.new(@template)
       .result_with_hash({ role_id:, course_name: course.name, meeting_date: formatted_date(minute.meeting_date), url: new_minute_attendance_url(minute) })
  end

  private

  def role_id
    ENV.fetch('TEAM_MEMBER_ROLE_ID', nil).to_i
  end

  def formatted_date(date)
    day_of_the_week = %w[日 月 火 水 木 金 土][date.wday]
    "#{date.strftime('%Y年%m月%d日')}(#{day_of_the_week})"
  end
end
