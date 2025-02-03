# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceForm, type: :model do
  describe 'when create attendance' do
    let(:minute) { FactoryBot.create(:minute) }
    let(:member) { FactoryBot.create(:member, course: minute.course) }

    it 'can create an attendance to afternoon session' do
      attributes_when_attend_afternoon_session = { status: 'afternoon' }
      expect do
        described_class.new(model: Attendance.new, minute:, member:, **attributes_when_attend_afternoon_session).save
      end.to change(Attendance, :count).by(1)
    end

    it 'can create an attendance to night session' do
      attributes_when_attend_night_session = { status: 'night' }
      expect do
        described_class.new(model: Attendance.new, minute:, member:, **attributes_when_attend_night_session).save
      end.to change(Attendance, :count).by(1)
    end

    it 'can create an attendance as absence' do
      attributes_when_absent_from_meeting = { status: 'absent', absence_reason: '職場のイベントに参加するため', progress_report: '#1200 PRを作成しレビュー依頼中です。' }
      expect do
        described_class.new(model: Attendance.new, minute:, member:, **attributes_when_absent_from_meeting).save
      end.to change(Attendance, :count).by(1)
    end

    it 'cannot create an attendance with invalid attributes' do
      attributes_without_status = { status: nil }
      attendance_form = described_class.new(model: Attendance.new, minute:, member:, **attributes_without_status)
      expect do
        attendance_form.save
      end.not_to change(Attendance, :count)

      attributes_without_absence_reason_and_progress_report = { status: 'absent' }
      attendance_form = described_class.new(model: Attendance.new, minute:, member:, **attributes_without_absence_reason_and_progress_report)
      expect do
        attendance_form.save
      end.not_to change(Attendance, :count)
    end
  end

  describe 'when update attendance' do
    let(:minute) { FactoryBot.create(:minute) }
    let(:member) { FactoryBot.create(:member, course: minute.course) }
    let(:attendance) { FactoryBot.create(:attendance, minute:, member:) }

    it 'can update an attendance with valid attributes' do
      expect(attendance.present).to be true
      expect(attendance.session).to eq 'afternoon'
      expect(attendance.absence_reason).to be_nil
      expect(attendance.progress_report).to be_nil

      valid_attributes = { status: 'absent', absence_reason: '職場のイベントに参加するため', progress_report: '#1200 PRを作成しレビュー依頼中です。' }
      attendance_form = described_class.new(model: attendance, minute:, member:, **valid_attributes)
      attendance_form.save
      expect(attendance.present).to be false
      expect(attendance.session).to be_nil
      expect(attendance.absence_reason).to eq '職場のイベントに参加するため'
      expect(attendance.progress_report).to eq '#1200 PRを作成しレビュー依頼中です。'
    end

    it 'cannot update an attendance with invalid attributes' do
      expect(attendance.present).to be true

      attributes_without_absence_reason_and_progress_report = { status: 'absent' }
      attendance_form = described_class.new(model: attendance, minute:, member:, **attributes_without_absence_reason_and_progress_report)
      attendance_form.save
      expect(attendance.present).to be true
    end
  end
end
