# frozen_string_literal: true

class Courses::MembersController < Courses::ApplicationController
  def index
    members = params[:status] == 'hibernated' ? Member.hibernated : Member.active
    members = Member.active unless admin_signed_in?
    @members = members.where(course: @course).order(:created_at)
  end
end
