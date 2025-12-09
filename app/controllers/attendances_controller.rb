# frozen_string_literal: true

class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[edit update]
  before_action :prohibit_edit_attendance_to_finished_meeting, only: %i[edit update]

  def edit
    @attendance_form = AttendanceForm.new(model: @attendance)
  end

  def update
    @attendance_form = AttendanceForm.new(model: @attendance, **attendance_form_params)
    if @attendance_form.save
      redirect_to edit_minute_path(@attendance.minute), notice: t('.success')
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def attendance_form_params
    params.require(:attendance_form).permit(:status, :absence_reason, :progress_report)
  end

  def set_attendance
    @attendance = current_member.attendances.find(params[:id])
  end

  def prohibit_edit_attendance_to_finished_meeting
    redirect_to edit_minute_url(@attendance.minute), alert: t('.failure') if @attendance.meeting.already_finished?
  end
end
