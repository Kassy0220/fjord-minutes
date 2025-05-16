# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# add course data
courses_data = [{ name: 'Railsエンジニアコース', meeting_week: :odd, kind: :back_end }, { name: 'フロントエンドエンジニアコース', meeting_week: :even, kind: :front_end }]
courses = courses_data.map do |course_data|
  Course.find_or_create_by!(name: course_data[:name]) do |course|
    course.meeting_week = course_data[:meeting_week]
  end
end
rails_course = courses.first

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
    member.course = rails_course
  end
end

# Memberのcreated_atにシード実行の日時が保存されると期待した通りに出席を取得できない可能性があるため、created_atの日付を固定しておく
members.each do |member|
  member.update!(created_at: Time.zone.local(2025, 1, 1))
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

# add meeting data
Meeting.find_or_create_by!(date: Time.zone.local(2025, 1, 15), course: rails_course)

23.times do
  meeting_date = rails_course.meetings.order(:date).last.next_date
  Meeting.find_or_create_by!(date: meeting_date, course: rails_course)
end

meetings = rails_course.meetings

# add minute data
minutes = meetings.map do |meeting|
  Minute.find_or_create_by!(meeting: meeting) do |minute|
    minute.release_branch = ''
    minute.release_note = ''
    minute.other = ''
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

meetings.each do |meeting|
  Attendance.find_or_create_by!(meeting:, member: day_attendee) do |attendance|
    attendance.attended = true
    attendance.session = :afternoon
  end
  Attendance.find_or_create_by!(meeting:, member: night_attendee) do |attendance|
    attendance.attended = true
    attendance.session = :night
  end
  Attendance.find_or_create_by!(meeting:, member: absentee) do |attendance|
    attendance.attended = false
    attendance.absence_reason = '仕事の都合のため'
    attendance.progress_report = '今週の進捗はありません、仕事が忙しく時間が取れずにいます。'
  end
end

meetings.where(date: ..hibernated_member_hibernation.created_at).find_each do |meeting|
  Attendance.find_or_create_by!(meeting:, member: hibernated_member) do |attendance|
    attendance.attended = true
    attendance.session = :afternoon
  end
end

meetings.where.not(date: returned_member_hibernation.created_at..returned_member_hibernation.finished_at).find_each do |meeting|
  Attendance.find_or_create_by!(meeting:, member: returned_member) do |attendance|
    attendance.attended = true
    attendance.session = :night
  end
end
