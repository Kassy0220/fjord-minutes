# frozen_string_literal: true

class Members::HibernationsController < Members::ApplicationController
  before_action :authenticate_admin!

  def create
    @member.hibernations.create!
    redirect_to course_members_path(@member.course, status: 'hibernated'), notice: "#{@member.name}を休止中にしました"
  end
end
