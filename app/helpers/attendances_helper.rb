# frozen_string_literal: true

module AttendancesHelper
  def attendance_status(present, time)
    return '---' if present.nil?

    { 'afternoon' => '昼', 'night' => '夜' }[time]
  end
end
