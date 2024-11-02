# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  describe '#meeting_years' do
    let(:course) { FactoryBot.build(:rails_course) }

    it 'returns all years which the meeting was held' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 1), course:)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course:)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2026, 1, 1), course:)
      expect(course.meeting_years).to contain_exactly(2024, 2025, 2026)
    end
  end
end
