# frozen_string_literal: true

class Courses::MinutesController < Courses::ApplicationController
  def index
    return @minutes = [] if @course.minutes.none?

    year = params[:year] ? params[:year].to_i : @course.meeting_years.max
    @minutes = @course.minutes.includes(:course, :meeting).where(meetings: { date: Time.zone.local(year).all_year }).order(meetings: { date: :asc })
  end
end
