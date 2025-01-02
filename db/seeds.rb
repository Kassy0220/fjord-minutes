# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# add course data
courses_data = [{ name: 'Railsエンジニアコース', meeting_week: :odd }, { name: 'フロントエンドエンジニアコース', meeting_week: :even }]
courses = courses_data.map do |course_data|
  Course.find_or_create_by!(name: course_data[:name]) do |course|
    course.meeting_week = course_data[:meeting_week]
  end
end

# add member data
members_data = [
  {
    email: 'day_attendee@example.com',
    name: 'day_attendee'
  },
  {
    email: 'night_attendee@example.com',
    name: 'night_attendee'
  },
  {
    email: 'absentee@example.com',
    name: 'absentee'
  },
  {
    email: 'unexcused_absentee@example.com',
    name: 'unexcused_absentee'
  },
  {
    email: 'hibernated_member@example.com',
    name: 'hibernated_member'
  },
  {
    email: 'returned_member@example.com',
    name: 'returned_member'
  },
  {
    email: 'rookie_member@example.com',
    name: 'rookie_member'
  }
]

members = members_data.map do |member_data|
  Member.find_or_create_by!(email: member_data[:email]) do |member|
    member.password = 'password'
    member.provider = 'developer'    # developer認証でログインできるように、providerはdeveloperにしておく
    member.uid = member_data[:email] # developer認証でログインできるように、uidにはemailの値にしておく
    member.name = member_data[:name]
    member.avatar_url = 'https://i.gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3.png'
    member.course = courses.first
  end
end

rookie_member = Member.find_by(email: 'rookie_member@example.com')
rookie_member.update!(created_at: Time.zone.local(2026, 1, 10))

# add admin data
admins_data = [
  {
    email: 'komagata@example.com',
    uid: 211_111,
    name: 'komagata'
  }
]

admins = admins_data.map do |admin_data|
  Admin.find_or_create_by!(email: admin_data[:email]) do |admin|
    admin.password = 'password'
    admin.provider = 'github'
    admin.uid = admin_data[:uid]
    admin.name = admin_data[:name]
    admin.avatar_url = 'https://i.gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3.png'
  end
end

# add member hibernation data
hibernated_member = Member.find_by(email: 'hibernated_member@example.com')
hibernated_member_hibernation = hibernated_member.hibernations.create!
hibernated_member_hibernation.update!(created_at: Time.zone.local(2025, 6, 30))

returned_member = Member.find_by(email: 'returned_member@example.com')
returned_member_hibernation = returned_member.hibernations.create!
returned_member_hibernation.update!(created_at: Time.zone.local(2025, 6, 30), finished_at: Time.zone.local(2025, 8, 15))

# add minute data
meeting_dates = [
  { meeting_date: Time.zone.local(2025, 1, 15), next_meeting_date: Time.zone.local(2025, 2, 5) },
  { meeting_date: Time.zone.local(2025, 2, 5), next_meeting_date: Time.zone.local(2025, 2, 19) },
  { meeting_date: Time.zone.local(2025, 2, 19), next_meeting_date: Time.zone.local(2025, 3, 5) },
  { meeting_date: Time.zone.local(2025, 3, 5), next_meeting_date: Time.zone.local(2025, 3, 19) },
  { meeting_date: Time.zone.local(2025, 3, 19), next_meeting_date: Time.zone.local(2025, 4, 2) },
  { meeting_date: Time.zone.local(2025, 4, 2), next_meeting_date: Time.zone.local(2025, 4, 16) },
  { meeting_date: Time.zone.local(2025, 4, 16), next_meeting_date: Time.zone.local(2025, 5, 7) },
  { meeting_date: Time.zone.local(2025, 5, 7), next_meeting_date: Time.zone.local(2025, 5, 21) },
  { meeting_date: Time.zone.local(2025, 5, 21), next_meeting_date: Time.zone.local(2025, 6, 4) },
  { meeting_date: Time.zone.local(2025, 6, 4), next_meeting_date: Time.zone.local(2025, 6, 18) },
  { meeting_date: Time.zone.local(2025, 6, 18), next_meeting_date: Time.zone.local(2025, 7, 2) },
  { meeting_date: Time.zone.local(2025, 7, 2), next_meeting_date: Time.zone.local(2025, 7, 16) },
  { meeting_date: Time.zone.local(2025, 7, 16), next_meeting_date: Time.zone.local(2025, 8, 6) },
  { meeting_date: Time.zone.local(2025, 8, 6), next_meeting_date: Time.zone.local(2025, 8, 20) },
  { meeting_date: Time.zone.local(2025, 8, 20), next_meeting_date: Time.zone.local(2025, 9, 3) },
  { meeting_date: Time.zone.local(2025, 9, 3), next_meeting_date: Time.zone.local(2025, 9, 17) },
  { meeting_date: Time.zone.local(2025, 9, 17), next_meeting_date: Time.zone.local(2025, 10, 1) },
  { meeting_date: Time.zone.local(2025, 10, 1), next_meeting_date: Time.zone.local(2025, 10, 15) },
  { meeting_date: Time.zone.local(2025, 10, 15), next_meeting_date: Time.zone.local(2025, 11, 5) },
  { meeting_date: Time.zone.local(2025, 11, 5), next_meeting_date: Time.zone.local(2025, 11, 19) },
  { meeting_date: Time.zone.local(2025, 11, 19), next_meeting_date: Time.zone.local(2025, 12, 3) },
  { meeting_date: Time.zone.local(2025, 12, 3), next_meeting_date: Time.zone.local(2025, 12, 17) },
  { meeting_date: Time.zone.local(2025, 12, 17), next_meeting_date: Time.zone.local(2026, 1, 7) },
  { meeting_date: Time.zone.local(2026, 1, 7), next_meeting_date: Time.zone.local(2026, 1, 21) }
]

minutes = meeting_dates.map do |date|
  Minute.find_or_create_by(meeting_date: date[:meeting_date]) do |minute|
    minute.release_branch = ''
    minute.release_note = ''
    minute.other = ''
    minute.meeting_date = date[:meeting_date]
    minute.next_meeting_date = date[:next_meeting_date]
    minute.course = courses.first
  end
end

# add topic data
Topic.find_or_create_by!(minute: minutes.last, topicable: members.first) { |topic| topic.content = 'CI上でテストが落ちてしまいます' }
Topic.find_or_create_by!(minute: minutes.last, topicable: members.second) { |topic| topic.content = '動作確認のお手伝いをしてくださる方を募集中です' }
Topic.find_or_create_by!(minute: minutes.last, topicable: admins.first) { |topic| topic.content = '合同企業説明会がありますので是非ご参加ください' }

# add attendance data
day_attendee = Member.find_by(email: 'day_attendee@example.com')
night_attendee = Member.find_by(email: 'night_attendee@example.com')
absentee = Member.find_by(email: 'absentee@example.com')

minutes.each do |minute|
  Attendance.find_or_create_by!(minute:, member: day_attendee) do |attendance|
    attendance.status = :present
    attendance.time = :day
  end
  Attendance.find_or_create_by!(minute:, member: night_attendee) do |attendance|
    attendance.status = :present
    attendance.time = :night
  end
  Attendance.find_or_create_by!(minute:, member: absentee) do |attendance|
    attendance.status = :absent
    attendance.absence_reason = '仕事の都合のため'
    attendance.progress_report = '今週の進捗はありません、仕事が忙しく時間が取れずにいます。'
  end
end

Minute.where(meeting_date: ..hibernated_member_hibernation.created_at).find_each do |minute|
  Attendance.find_or_create_by!(minute:, member: hibernated_member) do |attendance|
    attendance.status = :present
    attendance.time = :day
  end
end

Minute.where.not(meeting_date: returned_member_hibernation.created_at..returned_member_hibernation.finished_at).find_each do |minute|
  Attendance.find_or_create_by!(minute:, member: returned_member) do |attendance|
    attendance.status = :present
    attendance.time = :night
  end
end
