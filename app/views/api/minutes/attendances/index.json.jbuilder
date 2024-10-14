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
