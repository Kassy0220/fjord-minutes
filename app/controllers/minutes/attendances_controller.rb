# frozen_string_literal: true

class Minutes::AttendancesController < Minutes::ApplicationController
  before_action :redirect_admin_access, only: %i[new create]

  def new
    redirect_to edit_minute_url(@minute), alert: 'すでに出席を登録済みです' if already_registered_attendance
    redirect_to edit_minute_url(@minute), alert: '終了したミーティングには出席できません' if @minute.already_finished?

    @attendance = Attendance.new
  end

  def create
    redirect_to edit_minute_url(@minute), alert: 'すでに出席を登録済みです' if already_registered_attendance
    redirect_to edit_minute_url(@minute), alert: '終了したミーティングには出席できません' if @minute.already_finished?

    @attendance = @minute.attendances.new(attendance_params)
    @attendance.member_id = current_member.id

    if @attendance.save
      redirect_to edit_minute_url(@minute), notice: "#{Attendance.model_name.human}を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:status, :time, :absence_reason, :progress_report)
  end

  def already_registered_attendance
    @minute.attendances.where(member_id: current_member.id).any?
  end

  def redirect_admin_access
    redirect_to edit_minute_url(@minute) if admin_signed_in?
  end
end
