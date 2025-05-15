# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  describe 'validation' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:rails_course_member) { FactoryBot.create(:member, course: rails_course) }

    it 'is valid when attend belonged course meeting' do
      rails_course_meeting = FactoryBot.create(:meeting, course: rails_course)
      attendance = FactoryBot.build(:attendance, member: rails_course_member, meeting: rails_course_meeting)
      expect(attendance.valid?).to be true
    end

    it 'is invalid when attend other course meeting' do
      front_end_course = FactoryBot.create(:front_end_course)
      front_end_course_meeting = FactoryBot.create(:meeting, course: front_end_course)
      attendance = FactoryBot.build(:attendance, member: rails_course_member, meeting: front_end_course_meeting)
      expect(attendance.valid?).to be false
      expect(attendance.errors[:meeting]).to include('は自分の所属するコースのミーティングを選択してください')
    end
  end
end
