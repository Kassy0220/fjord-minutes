# frozen_string_literal: true

class AttendancesController < ApplicationController
  def edit
    attendance = current_member.attendances.find(params[:id])
    redirect_to edit_minute_url(attendance.minute), alert: '終了したミーティングの出席予定は変更できません' if attendance.minute.already_finished?

    @attendance_form = AttendanceForm.new(model: attendance)
  end

  def update
    attendance = current_member.attendances.find(params[:id])
    redirect_to edit_minute_url(attendance.minute), alert: '終了したミーティングの出席予定は変更できません' if attendance.minute.already_finished?

    @attendance_form = AttendanceForm.new(model: attendance, **attendance_form_params)
    if @attendance_form.save
      redirect_to edit_minute_path(attendance.minute), notice: '出席予定を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def attendance_form_params
    params.require(:attendance_form).permit(:status, :absence_reason, :progress_report)
  end
end
