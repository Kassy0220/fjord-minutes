json.afternoon_attendees do
  json.array! @attendances.at_afternoon_session do |attendance|
    json.attendance_id attendance.id
    json.member_id attendance.member_id
    json.name attendance.member.name
  end
end

json.night_attendees do
  json.array! @attendances.at_night_session do |attendance|
    json.attendance_id attendance.id
    json.member_id attendance.member_id
    json.name attendance.member.name
  end
end

json.absentees do
  json.array! @attendances.absent do |attendance|
    json.attendance_id attendance.id
    json.member_id attendance.member_id
    json.name attendance.member.name
    json.absence_reason attendance.absence_reason
    json.progress_report attendance.progress_report
  end
end

json.unexcused_absentees do
  json.array! @unexcused_absentees do |absentee|
    json.member_id absentee.id
    json.name absentee.name
  end
end
