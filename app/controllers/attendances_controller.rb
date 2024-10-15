class AttendancesController < ApplicationController
  def edit
    @attendance = current_member.attendances.find(params[:id])
  end

  def update
    @attendance = current_member.attendances.find(params[:id])
    remove_unnecessary_values

    if @attendance.update(attendance_params)
      redirect_to edit_minute_path(@attendance.minute_id), notice: "Attendance was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def attendance_params
    params.require(:attendance).permit(:status, :time, :absence_reason, :progress_report)
  end

  def remove_unnecessary_values
    if attendance_params["status"] == "present"
      @attendance.absence_reason = nil
      @attendance.progress_report = nil
    elsif attendance_params["status"] == "absent"
      @attendance.time = nil
    end
  end
end
