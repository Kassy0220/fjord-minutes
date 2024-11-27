# frozen_string_literal: true

module AttendancesHelper
  def attendance_status(status, time)
    return '---' if status.nil?

    { 'day' => '昼', 'night' => '夜' }[time]
  end
end
