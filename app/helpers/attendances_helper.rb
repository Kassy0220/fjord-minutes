# frozen_string_literal: true

module AttendancesHelper
  def attendance_status(present, time)
    return '---' unless present

    { 'afternoon' => '昼', 'night' => '夜' }[time]
  end
end
