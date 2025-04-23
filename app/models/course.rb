# frozen_string_literal: true

class Course < ApplicationRecord
  include Rails.application.routes.url_helpers
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze
  TEMPLATE_FOR_MINUTE_CREATION = 'config/templates/minute_creation_message.md'

  enum :meeting_week, { odd: 0, even: 1 }, suffix: true
  enum :kind, { back_end: 0, front_end: 1 }, suffix: true

  has_many :meetings, dependent: :restrict_with_exception
  has_many :minutes, through: :meetings
  has_many :members, dependent: :restrict_with_exception

  def meeting_years
    meetings.map { |meeting| meeting.date.year }.uniq
  end

  def repository_url
    { 'back_end' => 'https://github.com/fjordllc/bootcamp', 'front_end' => 'https://github.com/fjordllc/agent' }[kind]
  end

  def wiki_repository_url
    { 'back_end' => ENV.fetch('BOOTCAMP_WIKI_URL'), 'front_end' => ENV.fetch('AGENT_WIKI_URL') }[kind]
  end

  def discord_webhook_url
    { 'back_end' => ENV.fetch('RAILS_COURSE_CHANNEL_URL', nil), 'front_end' => ENV.fetch('FRONT_END_COURSE_CHANNEL_URL', nil) }[kind]
  end

  def create_next_meeting_and_minute
    last_meeting_date, next_meeting_date = latest_meeting_schedule

    unless last_meeting_date.before? Time.zone.today
      Rails.logger.info("create_next_meeting_and_minute, #{name}, not_executed, last meeting isn't finished.")
      return
    end

    next_meeting = meetings.create!(date: next_meeting_date)
    next_meeting.create_minute!
    Rails.logger.info("create_next_meeting_and_minute, #{name}, executed")
    notification_message = ERB.new(File.read(TEMPLATE_FOR_MINUTE_CREATION))
                              .result_with_hash({ discord_role_id:, course_name: name, meeting_date: I18n.l(next_meeting_date, format: :long), url: new_meeting_attendance_url(next_meeting) })
    Discord::Notifier.message(notification_message, url: discord_webhook_url)
  end

  private

  def latest_meeting_schedule
    if meetings.exists?
      latest_meeting = meetings.order(:date).last
      return [latest_meeting.date, latest_meeting.next_date]
    end

    cloned_repository_path = kind == 'back_end' ? CLONED_BOOTCAMP_WIKI_PATH : CLONED_AGENT_WIKI_PATH
    Git.clone(wiki_repository_url, cloned_repository_path) unless File.exist?(cloned_repository_path)

    latest_meeting_date = get_latest_meeting_date_from_cloned_minutes(cloned_repository_path)
    next_meeting_date = get_next_meeting_date_from_cloned_minutes(latest_meeting_date, cloned_repository_path)
    [latest_meeting_date, next_meeting_date]
  end

  def get_latest_meeting_date_from_cloned_minutes(repository_path)
    Dir.glob('ふりかえり・計画ミーティング*', base: repository_path).map do |filename|
      _, year, month, day = *filename.match(/ふりかえり・計画ミーティング(\d{4})年(\d{2})月(\d{2})/)
      Date.new(year.to_i, month.to_i, day.to_i) # Time.zone.today(返り値はDateクラス)と比較を行うために、Dateクラスでインスタンス化する
    end.max
  end

  def get_next_meeting_date_from_cloned_minutes(date, repository_path)
    filename = "ふりかえり・計画ミーティング#{I18n.l(date)}.md"
    minute_content = File.read(File.join(repository_path, filename))
    _, year, month, day = *minute_content.match(/# 次回のMTG\n\n- (\d{4})年(\d{2})月(\d{2})日/)
    Date.new(year.to_i, month.to_i, day.to_i)
  end

  def discord_role_id
    ENV.fetch('TEAM_MEMBER_ROLE_ID', nil).to_i
  end
end
