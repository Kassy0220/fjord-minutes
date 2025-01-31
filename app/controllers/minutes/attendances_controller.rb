# frozen_string_literal: true

class Minutes::AttendancesController < Minutes::ApplicationController
  before_action :redirect_admin_access, only: %i[new create]
  before_action :prohibit_duplicate_access, only: %i[new create]
  before_action :prohibit_access_to_finished_minute, only: %i[new create]

  def new
    @attendance = Attendance.new
  end

  def create
    @attendance = @minute.attendances.new(attendance_params)
    @attendance.member_id = current_member.id

    if @attendance.save
      redirect_to edit_minute_url(@minute), notice: '出席予定を登録しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:status, :session, :absence_reason, :progress_report)
  end

  def already_registered_attendance
    @minute.attendances.where(member_id: current_member.id).any?
  end

  def redirect_admin_access
    redirect_to edit_minute_url(@minute) if admin_signed_in?
  end

  def prohibit_duplicate_access
    redirect_to edit_minute_url(@minute), alert: 'すでに出席予定を登録済みです' if @minute.attendances.where(member_id: current_member.id).any?
  end

  def prohibit_access_to_finished_minute
    redirect_to edit_minute_url(@minute), alert: '終了したミーティングには出席予定を登録できません' if @minute.already_finished?
  end
end
