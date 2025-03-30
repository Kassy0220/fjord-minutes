# frozen_string_literal: true

class MeetingSecretary
  CLONED_BOOTCAMP_WIKI_PATH = Rails.root.join('bootcamp_wiki_repository').freeze
  CLONED_AGENT_WIKI_PATH = Rails.root.join('agent_wiki_repository').freeze

  def self.prepare_for_meeting
    Course.find_each do |course|
      secretary = new(course)
      course.minutes.none? ? secretary.create_first_minute : secretary.create_minute
      secretary.notify_today_meeting
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

    new_minute = @course.minutes.create!(meeting_date:, next_meeting_date:)
    leave_log("create_minute, #{@course.name}, executed")
    Discord::Notifier.message(NotificationMessageBuilder.build(:minute_creation, @course, new_minute), url: @course.discord_webhook_url)
  end

  def create_first_minute
    cloned_repository_path = rails_course? ? CLONED_BOOTCAMP_WIKI_PATH : CLONED_AGENT_WIKI_PATH
    Git.clone(wiki_repository_url, cloned_repository_path) unless File.exist?(cloned_repository_path)

    latest_meeting_date = get_latest_meeting_date_from_cloned_minutes(cloned_repository_path)
    unless latest_meeting_date.before? Time.zone.today
      leave_log("create_first_minute, #{@course.name}, not_executed, latest meeting isn't finished.")
      return
    end

    meeting_date = get_next_meeting_date_from_cloned_minutes(latest_meeting_date, cloned_repository_path)
    next_meeting_date = MeetingDateCalculator.next_meeting_date(meeting_date, @course.meeting_week)

    new_minute = @course.minutes.create!(meeting_date:, next_meeting_date:)
    leave_log("create_first_minute, #{@course.name}, executed")
    Discord::Notifier.message(NotificationMessageBuilder.build(:minute_creation, @course, new_minute), url: @course.discord_webhook_url)
  end

  def notify_today_meeting
    if @course.minutes.none?
      leave_log("notify_today_meeting, #{@course.name}, not_executed, There are no minutes yet.")
      return
    end

    latest_minute = @course.minutes.order(:created_at).last
    unless latest_minute.meeting_date == Time.zone.today
      leave_log("notify_today_meeting, #{@course.name}, not_executed, Today is not meeting day.")
      return
    end

    if latest_minute.notified_at
      leave_log("notify_today_meeting, #{@course.name}, not_executed, Notification was already sent.")
      return
    end

    Discord::Notifier.message(NotificationMessageBuilder.build(:today_meeting, @course, latest_minute), url: @course.discord_webhook_url)
    leave_log("notify_today_meeting, #{@course.name}, executed")
    latest_minute.update!(notified_at: Time.zone.now)
  end

  private

  def wiki_repository_url
    rails_course? ? ENV.fetch('BOOTCAMP_WIKI_URL', nil) : ENV.fetch('AGENT_WIKI_URL', nil)
  end

  def rails_course?
    @course.name == 'Railsエンジニアコース'
  end

  def get_latest_meeting_date_from_cloned_minutes(repository_path)
    Dir.glob('ふりかえり・計画ミーティング*', base: repository_path).map do |filename|
      _, year, month, day = *filename.match(/ふりかえり・計画ミーティング(\d{4})年(\d{2})月(\d{2})/)
      Date.new(year.to_i, month.to_i, day.to_i) # Time.zone.today(返り値はDateクラス)と比較を行うために、Dateクラスでインスタンス化する
    end.max
  end

  def get_next_meeting_date_from_cloned_minutes(meeting_date, repository_path)
    filename = "ふりかえり・計画ミーティング#{I18n.l(meeting_date)}.md"
    minute_content = File.read(File.join(repository_path, filename))
    _, year, month, day = *minute_content.match(/# 次回のMTG\n\n- (\d{4})年(\d{2})月(\d{2})日/)
    Time.zone.local(year.to_i, month.to_i, day.to_i)
  end

  def leave_log(message)
    Rails.logger.info(message)
  end
end
