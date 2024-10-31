# frozen_string_literal: true

class NotificationMessageBuilder
  include Rails.application.routes.url_helpers
  TEMPLATE_PATH_FOR_MINUTE_CREATION = 'config/templates/minute_creation_message.md'
  TEMPLATE_PATH_FOR_TODAY_MEETING = 'config/templates/today_meeting_message.md'

  def self.build(message_type, course, minute)
    new(message_type).build(course, minute)
  end

  def initialize(message_type)
    @template = File.read(template_path(message_type))
  end

  def build(course, minute)
    ERB.new(@template)
       .result_with_hash({ role_id:, course_name: course.name, meeting_date: formatted_date(minute.meeting_date), url: new_minute_attendance_url(minute) })
  end

  private

  def template_path(type)
    { minute_creation: TEMPLATE_PATH_FOR_MINUTE_CREATION, today_meeting: TEMPLATE_PATH_FOR_TODAY_MEETING }[type]
  end

  def role_id
    ENV.fetch('TEAM_MEMBER_ROLE_ID', nil).to_i
  end

  def formatted_date(date)
    day_of_the_week = %w[日 月 火 水 木 金 土][date.wday]
    "#{date.strftime('%Y年%m月%d日')}(#{day_of_the_week})"
  end
end
