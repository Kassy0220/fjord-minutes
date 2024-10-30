# frozen_string_literal: true

class MeetingSecretary
  def self.prepare_for_meeting
    Course.find_each do |course|
      secretary = new(course)
      course.minutes.none? ? secretary.create_first_minute : secretary.create_minute
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
    Discord::Notifier.message(NotificationMessageBuilder.build(@course, new_minute), url: webhook_url)
  end

  def create_first_minute
    cloned_repository_path = GithubWikiManager.new(@course).working_directory
    latest_meeting_date = get_latest_meeting_date_from_cloned_minutes(cloned_repository_path)
    unless latest_meeting_date.before? Time.zone.today
      leave_log("create_first_minute, #{@course.name}, not_executed, latest meeting isn't finished.")
      return
    end

    meeting_date = get_next_meeting_date_from_cloned_minutes(latest_meeting_date, cloned_repository_path)
    next_meeting_date = MeetingDateCalculator.next_meeting_date(meeting_date, @course.meeting_week)

    new_minute = @course.minutes.create!(meeting_date:, next_meeting_date:)
    leave_log("create_first_minute, #{@course.name}, executed")
    Discord::Notifier.message(NotificationMessageBuilder.build(@course, new_minute), url: webhook_url)
  end

  private

  def get_latest_meeting_date_from_cloned_minutes(repository_path)
    Dir.glob('ふりかえり・計画ミーティング*', base: repository_path).map do |filename|
      _, year, month, day = *filename.match(/ふりかえり・計画ミーティング(\d{4})年(\d{2})月(\d{2})/)
      Date.new(year.to_i, month.to_i, day.to_i)
    end.max
  end

  def get_next_meeting_date_from_cloned_minutes(meeting_date, repository_path)
    filename = "ふりかえり・計画ミーティング#{meeting_date.strftime('%Y年%m月%d日')}.md"
    minute_content = File.read(File.join(repository_path, filename))
    _, year, month, day = *minute_content.match(/# 次回のMTG\n\n- (\d{4})年(\d{2})月(\d{2})日/)
    Date.new(year.to_i, month.to_i, day.to_i)
  end

  def webhook_url
    @course.name == 'Railsエンジニアコース' ? ENV.fetch('RAILS_COURSE_CHANNEL_URL', nil) : ENV.fetch('FRONT_END_COURSE_CHANNEL_URL', nil)
  end

  def leave_log(message)
    Rails.logger.info(message)
  end
end
