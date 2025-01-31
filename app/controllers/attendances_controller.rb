# frozen_string_literal: true

class AttendancesController < ApplicationController
  def edit
    @attendance = current_member.attendances.find(params[:id])
    redirect_to edit_minute_url(@attendance.minute), alert: '終了したミーティングの出席予定は変更できません' if @attendance.minute.already_finished?
  end

  def update
    @attendance = current_member.attendances.find(params[:id])
    redirect_to edit_minute_url(@attendance.minute), alert: '終了したミーティングの出席予定は変更できません' if @attendance.minute.already_finished?

    remove_unnecessary_values

    if @attendance.update(attendance_params)
      redirect_to edit_minute_path(@attendance.minute_id), notice: '出席予定を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:status, :session, :absence_reason, :progress_report)
  end

  def remove_unnecessary_values
    if attendance_params['status'] == 'present'
      @attendance.absence_reason = nil
      @attendance.progress_report = nil
    elsif attendance_params['status'] == 'absent'
      @attendance.session = nil
    end
  end
end
