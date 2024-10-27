# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Minute, type: :model do
  describe '#already_finished?' do
    let(:minute) { FactoryBot.build(:minute) }

    it 'returns false if today is before the meeting date' do
      travel_to minute.meeting_date.days_ago(1) do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns false if today is the meeting date' do
      travel_to minute.meeting_date do
        expect(minute.already_finished?).to be false
      end
    end

    it 'returns true if today is after the meeting date' do
      travel_to minute.meeting_date.days_since(1) do
        expect(minute.already_finished?).to be true
      end
    end
  end
end
