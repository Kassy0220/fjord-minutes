# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:member) { FactoryBot.create(:member) }

  describe '#hibernated?' do
    it 'returns true when member is not returned from hibernation' do
      member.hibernations.create(finished_at: nil)
      expect(member.hibernated?).to be true
    end

    it 'returns false when member does not hibernate' do
      expect(member.hibernated?).to be false
    end

    it 'returns false when member is returned from hibernation' do
      member.hibernations.create(finished_at: Time.zone.today)
      expect(member.hibernated?).to be false
    end
  end

  describe '#all_attendances' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course, created_at: Time.zone.local(2024, 10, 1)) }
    let(:present_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course) }
    let(:absent_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 16), course: rails_course) }
    let!(:unexcused_absent_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 11, 6), course: rails_course) }

    before do
      FactoryBot.create(:attendance, member:, minute: present_minute)
      FactoryBot.create(:attendance, :absence, member:, minute: absent_minute)
    end

    it 'returns all attendances since the member sign up' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 9, 18), course: rails_course)
      expected_attendances = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), attendance_id: Attendance.first.id, present: true, session: 'afternoon', absence_reason: nil },
                              { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), attendance_id: Attendance.second.id, present: false, session: nil, absence_reason: '体調不良のため。' },
                              { minute_id: unexcused_absent_minute.id, date: Date.new(2024, 11, 6), attendance_id: nil, present: nil, session: nil, absence_reason: nil }]
      expect(member.all_attendances).to eq(expected_attendances)
    end

    it 'returns attendances until the hibernation started if the member is hibernated' do
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2024, 11, 1))

      attendances_until_hibernation = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), attendance_id: Attendance.first.id, present: true, session: 'afternoon', absence_reason: nil },
                                       { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), attendance_id: Attendance.second.id, present: false, session: nil, absence_reason: '体調不良のため。' }]
      expect(member.all_attendances).to eq(attendances_until_hibernation)
    end
  end

  describe '#recent_attendances' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course, created_at: Time.zone.local(2024, 12, 1)) }

    before do
      create_minutes(course: rails_course, first_meeting_date: Time.zone.local(2024, 12, 18), count: 13)
    end

    it 'returns recent attendances up to twelve' do
      first_attendance = { minute_id: rails_course.minutes.first.id, date: Date.new(2025, 12, 18), attendance_id: nil, present: nil, session: nil, absence_reason: nil }
      second_attendance = { minute_id: rails_course.minutes.second.id, date: Date.new(2025, 1, 1), attendance_id: nil, present: nil, session: nil, absence_reason: nil }
      last_attendance = { minute_id: rails_course.minutes.last.id, date: Date.new(2025, 6, 18), attendance_id: nil, present: nil, session: nil, absence_reason: nil }

      expect(member.recent_attendances.length).to eq 12
      expect(member.recent_attendances).not_to include(first_attendance)
      expect(member.recent_attendances).to include(second_attendance)
      expect(member.recent_attendances).to include(last_attendance)
    end

    it 'returns attendances until the hibernation started if the member is hibernated' do
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2024, 12, 31))
      expect(member.recent_attendances.length).to eq 1
      expect(member.recent_attendances.first[:date]).to eq Date.new(2024, 12, 18)
    end

    it 'returns attendances from the latest returned date if the member was hibernated' do
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2025, 1, 1), finished_at: Time.zone.local(2025, 1, 31))
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2025, 4, 1), finished_at: Time.zone.local(2025, 4, 30))
      expect(member.recent_attendances.length).to eq 4
      attendance_dates = member.recent_attendances.pluck(:date)
      expect(attendance_dates).to contain_exactly(Date.new(2025, 5, 7), Date.new(2025, 5, 21), Date.new(2025, 6, 4), Date.new(2025, 6, 18))
    end
  end
end
