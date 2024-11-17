# frozen_string_literal: true

class Courses::MembersController < Courses::ApplicationController
  def index
    members = target_members
    members = Member.active unless admin_signed_in?
    @members = members.where(course: @course).order(:created_at)
  end

  private

  def target_members
    scope = params[:status].nil? ? 'active' : params[:status]
    { 'active' => Member.active, 'hibernated' => Member.hibernated, 'completed' => Member.completed.where(hibernations: { finished_at: nil }) }[scope]
  end
end
