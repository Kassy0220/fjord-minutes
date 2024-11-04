# frozen_string_literal: true

class API::Minutes::AttendancesController < API::Minutes::ApplicationController
  def index
    @attendances = @minute.attendances.includes(:member).order(:member_id)
    @unexcused_absentees = Member.active.where(course_id: @minute.course_id).where.not(id: @attendances.pluck(:member_id)).order(:id)
  end
end
