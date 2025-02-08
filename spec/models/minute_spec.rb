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

  describe '#title' do
    it 'returns formatted minute title' do
      minute = FactoryBot.build(:minute, meeting_date: Time.zone.local(2025, 1, 8))
      expect(minute.title).to eq 'ふりかえり・計画ミーティング2025年01月08日'
    end
  end
end
