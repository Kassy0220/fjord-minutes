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
      expect(member.all_attendances).to match_array(expected_attendances)
    end

    it 'returns attendances until the hibernation started if the member is hibernated' do
      FactoryBot.create(:hibernation, member:, created_at: Time.zone.local(2024, 11, 1))

      october_attendances = [{ minute_id: present_minute.id, date: Date.new(2024, 10, 2), status: 'present', time: 'day', absence_reason: nil },
                             { minute_id: absent_minute.id, date: Date.new(2024, 10, 16), status: 'absent', time: nil, absence_reason: '体調不良のため。' }]
      expect(member.hibernated?).to be true
      expect(member.all_attendances).to match_array(october_attendances)
    end

    it 'attendances during hibernation period is treated as hibernation' do
      FactoryBot.create(:hibernation, finished_at: Time.zone.local(2024, 11, 30), member:, created_at: Time.zone.local(2024, 11, 1))

      attendance_during_hibernation = { minute_id: unexcused_absent_minute.id, date: Date.new(2024, 11, 6), status: 'hibernation', time: nil,
                                        absence_reason: nil }
      expect(member.all_attendances).to include(attendance_during_hibernation)
    end
  end

  describe '#completed?' do
    it 'returns true if completed date is saved' do
      completed_member = FactoryBot.create(:member, completed_at: Time.zone.today)
      expect(completed_member.completed?).to be true
    end

    it 'returns false if completed date is not saved' do
      not_completed_member = FactoryBot.create(:member)
      expect(not_completed_member.completed?).to be false
    end
  end
end
