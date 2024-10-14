json.day_attendees do
  json.array! @attendances.where(time: :day) do |attendance|
    json.attendance_id attendance.id
    json.name attendance.member.name
  end
end

json.night_attendees do
  json.array! @attendances.where(time: :night) do |attendance|
    json.attendance_id attendance.id
    json.name attendance.member.name
  end
end

json.absentees do
  json.array! @attendances.where(status: :absent) do |attendance|
    json.attendance_id attendance.id
    json.name attendance.member.name
    json.absence_reason attendance.absence_reason
    json.progress_report attendance.progress_report
  end
end
