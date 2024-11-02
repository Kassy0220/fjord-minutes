# frozen_string_literal: true

class Courses::MinutesController < Courses::ApplicationController
  def index
    year = params[:year] ? params[:year].to_i : @course.meeting_years.max
    @minutes = @course.minutes.where(meeting_date: Time.zone.local(year, 1, 1, 0, 0, 0)..Time.zone.local(year, 12, 31, 23, 59, 59)).order(:created_at)
  end
end
