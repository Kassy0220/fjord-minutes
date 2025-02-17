# frozen_string_literal: true

class Minutes::AttendancesController < Minutes::ApplicationController
  before_action :redirect_admin_access, only: %i[new create]
  before_action :prohibit_duplicate_access, only: %i[new create]
  before_action :prohibit_access_to_finished_minute, only: %i[new create]

  def new
    @attendance_form = AttendanceForm.new(model: Attendance.new, minute: @minute, member: current_member)
  end

  def create
    @attendance_form = AttendanceForm.new(model: Attendance.new, minute: @minute, member: current_member, **attendance_form_params)

    if @attendance_form.save
      redirect_to edit_minute_url(@minute), notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def attendance_form_params
    params.require(:attendance_form).permit(:status, :absence_reason, :progress_report)
  end

  def already_registered_attendance
    @minute.attendances.where(member_id: current_member.id).any?
  end

  def redirect_admin_access
    redirect_to edit_minute_url(@minute) if admin_signed_in?
  end

  def prohibit_duplicate_access
    redirect_to edit_minute_url(@minute), alert: t('.failure.duplicate_access') if @minute.attendances.where(member_id: current_member.id).any?
  end

  def prohibit_access_to_finished_minute
    redirect_to edit_minute_url(@minute), alert: t('.failure.finished_meeting') if @minute.already_finished?
  end
end
