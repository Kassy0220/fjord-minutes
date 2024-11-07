# frozen_string_literal: true

class Courses::MembersController < Courses::ApplicationController
  def index
    @members = Member.active.where(course: @course).order(:created_at)
  end
end
