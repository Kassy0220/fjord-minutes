# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe '#already_finished?' do
    let(:meeting) { FactoryBot.build(:meeting, course: FactoryBot.create(:rails_course)) }

    it 'returns false if today is before the meeting date' do
      travel_to meeting.date.yesterday do
        expect(meeting.already_finished?).to be false
      end
    end

    it 'returns false if today is the meeting date' do
      travel_to meeting.date do
        expect(meeting.already_finished?).to be false
      end
    end

    it 'returns true if today is after the meeting date' do
      travel_to meeting.date.tomorrow do
        expect(meeting.already_finished?).to be true
      end
    end
  end
end
