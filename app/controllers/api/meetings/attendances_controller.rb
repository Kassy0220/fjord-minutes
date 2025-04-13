# frozen_string_literal: true

class API::Meetings::AttendancesController < API::Meetings::ApplicationController
  def index
    @attendances = @meeting.attendances.includes(:member).order(:member_id)
    @unexcused_absentees = @meeting.course.members.active.where.not(id: @attendances.pluck(:member_id)).order(:id)
  end
end
