# frozen_string_literal: true

class MinutesController < ApplicationController
  before_action :set_minute, only: %i[show edit]
  before_action :prohibit_other_course_member_access, only: %i[edit]

  def show; end

  def edit
    @topics = Topic.includes(:topicable).where(minute: @minute).order(:created_at)
  end

  private

  def set_minute
    @minute = Minute.find(params[:id])
  end

  def prohibit_other_course_member_access
    return if admin_signed_in?

    redirect_to root_path, alert: t('.failure.other_course') unless @minute.course == current_member.course
  end
end
