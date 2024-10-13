class Minutes::AttendancesController < Minutes::ApplicationController
  def new
    redirect_to edit_minute_url(@minute), alert: "You already registered attendance!" if already_registered_attendance

    @attendance = Attendance.new
  end

  def create
    @attendance = @minute.attendances.new(attendance_params)
    @attendance.member_id = current_member.id

    if @attendance.save
      redirect_to edit_minute_url(@minute), notice: "Attendance was successfully created."
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
end
