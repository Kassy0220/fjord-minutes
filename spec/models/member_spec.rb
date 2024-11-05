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

    it 'returns all attendances since the member sign up' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 9, 18), course: rails_course)
      attendance = FactoryBot.create(:attendance, member:, minute: FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course))
      absence = FactoryBot.create(:attendance, :absence, member:,
                                                         minute: FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 16), course: rails_course))
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 11, 6), course: rails_course)

      member.update!(created_at: Time.zone.local(2024, 10, 1))
      expected_attendances = [{ date: Date.new(2024, 10, 2), attendance_id: attendance.id, status: 'present', time: 'day', absence_reason: nil },
                              { date: Date.new(2024, 10, 16), attendance_id: absence.id, status: 'absent', time: nil,
                                absence_reason: '体調不良のため。' },
                              { date: Date.new(2024, 11, 6), attendance_id: nil, status: nil, time: nil, absence_reason: nil }]

      expect(member.all_attendances).to match_array(expected_attendances)
    end
  end
end
