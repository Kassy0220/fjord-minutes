# frozen_string_literal: true

class Courses::MinutesController < Courses::ApplicationController
  def index
    @minutes = @course.minutes.order(:created_at)
  end
end
