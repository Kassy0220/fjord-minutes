# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesHelper, type: :helper do
  let(:member) { FactoryBot.create :member, course: FactoryBot.create(:rails_course) }

  describe '#split_attendances' do
    it 'splits attendances by year' do
      attendance_records = [
        { minute_id: 1, date: Date.new(2024, 12, 18), attendance_id: 1, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 2, date: Date.new(2025, 1, 15), attendance_id: 2, present: false, session: nil, absence_reason: '体調不良のため。' }
      ]
      expect(helper.split_attendances(attendance_records, member)).to eq({ 2024 => [[attendance_records.first]], 2025 => [[attendance_records.second]] })
    end

    it 'does not include attendances during hibernated period' do
      FactoryBot.create(:hibernation, finished_at: Time.zone.local(2024, 8, 10), member:, created_at: Time.zone.local(2024, 7, 10))

      attendance_records = [
        { minute_id: 1, date: Date.new(2024, 7, 3), attendance_id: 1, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 2, date: Date.new(2024, 7, 17), attendance_id: 2, present: nil, session: nil, absence_reason: nil },
        { minute_id: 3, date: Date.new(2024, 8, 7), attendance_id: 3, present: nil, session: nil, absence_reason: nil },
        { minute_id: 4, date: Date.new(2024, 8, 21), attendance_id: 4, present: true, session: 'afternoon', absence_reason: nil }
      ]
      attendance_record_before_hibernation = { minute_id: 1, date: Date.new(2024, 7, 3), attendance_id: 1, present: true, session: 'afternoon', absence_reason: nil }
      attendance_record_after_hibernation = { minute_id: 4, date: Date.new(2024, 8, 21), attendance_id: 4, present: true, session: 'afternoon', absence_reason: nil }

      expect(helper.split_attendances(attendance_records, member)).to eq({ 2024 => [[attendance_record_before_hibernation], [attendance_record_after_hibernation]] })
    end

    it 'splits attendances in half year' do
      attendance_records = [
        { minute_id: 1, date: Date.new(2024, 1, 3), attendance_id: 1, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 2, date: Date.new(2024, 1, 17), attendance_id: 2, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 3, date: Date.new(2024, 2, 7), attendance_id: 3, present: true, session: 'night', absence_reason: nil },
        { minute_id: 4, date: Date.new(2024, 2, 21), attendance_id: 4, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 5, date: Date.new(2024, 3, 6), attendance_id: 5, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 6, date: Date.new(2024, 3, 20), attendance_id: 6, present: true, session: 'night', absence_reason: nil },
        { minute_id: 7, date: Date.new(2024, 4, 3), attendance_id: 7, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 8, date: Date.new(2024, 4, 17), attendance_id: 8, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 9, date: Date.new(2024, 5, 1), attendance_id: 9, present: true, session: 'night', absence_reason: nil },
        { minute_id: 10, date: Date.new(2024, 5, 15), attendance_id: 10, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 11, date: Date.new(2024, 6, 5), attendance_id: 11, present: true, session: 'afternoon', absence_reason: nil },
        { minute_id: 12, date: Date.new(2024, 6, 19), attendance_id: 12, present: true, session: 'night', absence_reason: nil },
        { minute_id: 13, date: Date.new(2024, 7, 3), attendance_id: 13, present: true, session: 'afternoon', absence_reason: nil }
      ]

      divided_attendances = helper.split_attendances(attendance_records, member)[2024]
      expect(divided_attendances.length).to eq 2
      expect(divided_attendances.first.length).to eq 12
      expect(divided_attendances.first.last).to eq({ minute_id: 12, date: Date.new(2024, 6, 19), attendance_id: 12, present: true, session: 'night', absence_reason: nil })
      expect(divided_attendances.second.length).to eq 1
      expect(divided_attendances.second.first).to eq({ minute_id: 13, date: Date.new(2024, 7, 3), attendance_id: 13, present: true, session: 'afternoon', absence_reason: nil })
    end
  end

  describe '#attendance_status' do
    it 'returns 昼 for afternoon session attendance' do
      expect(helper.attendance_status(true, 'afternoon')).to eq '昼'
    end

    it 'returns 夜 for night session attendance' do
      expect(helper.attendance_status(true, 'night')).to eq '夜'
    end

    it 'returns hyphen for unexcused absence' do
      expect(helper.attendance_status(nil, nil)).to eq '---'
    end
  end
end
