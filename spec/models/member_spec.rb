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
    let(:member) { FactoryBot.create(:member, course: rails_course) }
    let(:present_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course) }
    let(:absent_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 16), course: rails_course) }
    let!(:unexcused_absent_minute) { FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 11, 6), course: rails_course) }

    before do
      member.update!(created_at: Time.zone.local(2024, 10, 1))
      FactoryBot.create(:attendance, member:, minute: present_minute)
      FactoryBot.create(:attendance, :absence, member:, minute: absent_minute)
    end

    it 'returns all attendances since the member sign up' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 9, 18), course: rails_course)
      expected_attendances = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), status: 'present', time: 'day', absence_reason: nil },
                              { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), status: 'absent', time: nil, absence_reason: '体調不良のため。' },
                              { minute_id: unexcused_absent_minute.id, date: Date.new(2024, 11, 6), status: nil, time: nil, absence_reason: nil }]
      expect(member.all_attendances).to eq({ 2024 => [expected_attendances] })
    end

    it 'returns attendances until the hibernation started if the member is hibernated' do
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2024, 11, 1))

      attendances_until_hibernation = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), status: 'present', time: 'day', absence_reason: nil },
                                       { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), status: 'absent', time: nil, absence_reason: '体調不良のため。' }]
      expect(member.all_attendances).to eq({ 2024 => [attendances_until_hibernation] })
    end

    it 'does not include attendances during hibernated period' do
      FactoryBot.create(:hibernation, finished_at: Time.zone.local(2024, 10, 31), member:, created_at: Time.zone.local(2024, 10, 3))

      attendances_before_hibernation = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), status: 'present', time: 'day', absence_reason: nil }]
      attendances_after_hibernation = [{ minute_id: unexcused_absent_minute.id, date: Date.new(2024, 11, 6), status: nil, time: nil, absence_reason: nil }]
      expect(member.all_attendances).to eq({ 2024 => [attendances_before_hibernation, attendances_after_hibernation] })
    end

    it 'divides attendances by year' do
      latest_minute = FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
      first_year_attendances = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), status: 'present', time: 'day', absence_reason: nil },
                                { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), status: 'absent', time: nil, absence_reason: '体調不良のため。' },
                                { minute_id: unexcused_absent_minute.id, date: Date.new(2024, 11, 6), status: nil, time: nil, absence_reason: nil }]
      second_year_attendances = [{ minute_id: latest_minute.id, date: Date.new(2025, 1, 1), status: nil, time: nil, absence_reason: nil }]
      expect(member.all_attendances).to eq({ 2024 => [first_year_attendances], 2025 => [second_year_attendances] })
    end

    it 'divides attendances in half of the year' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
      FactoryBot.build_list(:minute, 12) do |minute|
        minute.meeting_date = MeetingDateCalculator.next_meeting_date(rails_course.minutes.last.meeting_date, rails_course.meeting_week)
        minute.course = rails_course
        minute.save!
      end

      attendances_in_the_latest_year = member.all_attendances[2025]
      expect(attendances_in_the_latest_year.length).to eq 2
      expect(attendances_in_the_latest_year.first.length).to eq 12
      expect(attendances_in_the_latest_year.first.last[:date]).to eq Date.new(2025, 6, 18)

      expect(attendances_in_the_latest_year.second.length).to eq 1
      expect(attendances_in_the_latest_year.second.last[:date]).to eq Date.new(2025, 7, 2)
    end
  end
end
