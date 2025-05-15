# frozen_string_literal: true

class Meetings::AttendancesController < Meetings::ApplicationController
  before_action :redirect_admin_access, only: %i[new create]
  before_action :prohibit_duplicate_access, only: %i[new create]
  before_action :prohibit_access_to_finished_meeting, only: %i[new create]
  before_action :prohibit_other_course_member_access, only: %i[new create]

  def new
    @attendance_form = AttendanceForm.new(model: Attendance.new, meeting: @meeting, member: current_member)
  end

  def create
    @attendance_form = AttendanceForm.new(model: Attendance.new, meeting: @meeting, member: current_member, **attendance_form_params)

    if @attendance_form.save
      redirect_to edit_minute_url(@meeting.minute), notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def attendance_form_params
    params.require(:attendance_form).permit(:status, :absence_reason, :progress_report)
  end

  def already_registered_attendance
    @meeting.attendances.exists?(member_id: current_member.id)
  end

  def redirect_admin_access
    redirect_to edit_minute_url(@meeting.minute) if admin_signed_in?
  end

  def prohibit_duplicate_access
    redirect_to edit_minute_url(@meeting.minute), alert: t('.failure.duplicate_access') if @meeting.attendances.exists?(member_id: current_member.id)
  end

  def prohibit_access_to_finished_meeting
    redirect_to edit_minute_url(@meeting.minute), alert: t('.failure.finished_meeting') if @meeting.already_finished?
  end

  def prohibit_other_course_member_access
    redirect_to root_url, alert: t('.failure.other_course') unless @meeting.course == current_member.course
  end
end
