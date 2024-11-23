# frozen_string_literal: true

class Members::HibernationsController < Members::ApplicationController
  before_action :authenticate_admin!
  before_action :prohibit_duplicate_hibernations

  def create
    @member.hibernations.create!
    redirect_to course_members_path(@member.course, status: 'all'), notice: "#{@member.name}をチームメンバーから外しました"
  end

  private

  def prohibit_duplicate_hibernations
    return unless @member.hibernated?

    redirect_to course_members_path(@member.course, status: 'all'), alert: "#{@member.name}さんはすでにチームメンバーから外れています"
  end
end
