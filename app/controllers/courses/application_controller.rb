# frozen_string_literal: true

class Courses::ApplicationController < ApplicationController
  before_action :set_course

  private

  def set_course
    @course = Course.find(params[:course_id])
  end
end
