# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Minute, type: :model do
  describe '#already_finished?' do
    let(:minute) { FactoryBot.build(:minute) }

    it 'returns false if today is before the meeting date' do
      travel_to minute.meeting_date.yesterday do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns false if today is the meeting date' do
      travel_to minute.meeting_date do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns true if today is after the meeting date' do
      travel_to minute.meeting_date.tomorrow do
        expect(minute.already_finished?).to be true
      end
    end
  end
end
