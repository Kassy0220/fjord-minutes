# frozen_string_literal: true

class Members::HibernationsController < Members::ApplicationController
  before_action :authenticate_admin!
  before_action :prohibit_duplicate_hibernations

  def create
    @member.hibernations.create!
    redirect_to course_members_path(@member.course, status: 'hibernated'), notice: "#{@member.name}を休止中にしました"
  end

  private

  def prohibit_duplicate_hibernations
    return unless @member.hibernated?

    redirect_to course_members_path(@member.course, status: 'hibernated'), alert: "#{@member.name}さんはすでに休止中です"
  end
end
