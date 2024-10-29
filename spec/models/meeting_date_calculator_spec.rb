# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingDateCalculator, type: :model do
  describe '#next_meeting_date' do
    let(:rails_course) { FactoryBot.build(:rails_course) }
    let(:front_end_course) { FactoryBot.build(:front_end_course) }

    it 'returns two weeks later when meeting date is within two weeks' do
      meeting_date = Date.new(2024, 10, 2)
      expect(described_class.next_meeting_date(meeting_date, rails_course.meeting_week)).to eq Date.new(2024, 10, 16)

      meeting_date = Date.new(2024, 10, 9)
      expect(described_class.next_meeting_date(meeting_date, rails_course.meeting_week)).to eq Date.new(2024, 10, 23)
    end

    context 'when meeting date is outside two weeks' do
      it 'returns day of the first week of the next month when meeting week is odd' do
        meeting_date = Date.new(2024, 10, 16)
        expect(described_class.next_meeting_date(meeting_date, rails_course.meeting_week)).to eq Date.new(2024, 11, 6)
      end

      it 'returns day of the second week of the next month when meeting week is even' do
        meeting_date = Date.new(2024, 10, 23)
        expect(described_class.next_meeting_date(meeting_date, front_end_course.meeting_week)).to eq Date.new(2024, 11, 13)
      end
    end

    context 'when next meeting date is next year' do
      it 'returns day of the first week of next January when meeting week is odd' do
        meeting_date = Date.new(2024, 12, 18)
        expect(described_class.next_meeting_date(meeting_date, rails_course.meeting_week)).to eq Date.new(2025, 1, 1)
      end

      it 'returns day of the second week of next January when meeting week is even' do
        meeting_date = Date.new(2024, 12, 25)
        expect(described_class.next_meeting_date(meeting_date, front_end_course.meeting_week)).to eq Date.new(2025, 1, 8)
      end
    end
  end
end
