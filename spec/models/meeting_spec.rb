# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'sets next_date automatically on create' do
    let(:rails_course) { FactoryBot.build(:rails_course, meeting_week: :odd) }
    let(:front_end_course) { FactoryBot.build(:front_end_course, meeting_week: :even) }

    context 'when date is within two weeks' do
      it 'next_date is two weeks later' do
        rails_course_meeting = described_class.create!(date: Time.zone.local(2024, 10, 2), course: rails_course)
        expect(rails_course_meeting.next_date).to eq Date.new(2024, 10, 16)

        front_end_course_meeting = described_class.create!(date: Time.zone.local(2024, 10, 9), course: front_end_course)
        expect(front_end_course_meeting.next_date).to eq Date.new(2024, 10, 23)
      end
    end

    context 'when date is after fifteenth' do
      it 'next_date is the day of the first week of the next month when meeting week is odd' do
        meeting = described_class.create!(date: Time.zone.local(2024, 10, 16), course: rails_course)
        expect(meeting.next_date).to eq Date.new(2024, 11, 6)
      end

      it 'next_date is the day of the second week of the next month when meeting week is even' do
        meeting = described_class.create!(date: Time.zone.local(2024, 10, 23), course: front_end_course)
        expect(meeting.next_date).to eq Date.new(2024, 11, 13)
      end
    end

    context 'when next_date is next year' do
      it 'next_date is the day of the first week of next January when meeting week is odd' do
        meeting = described_class.create!(date: Time.zone.local(2024, 12, 18), course: rails_course)
        expect(meeting.next_date).to eq Date.new(2025, 1, 1)
      end

      it 'next_date is the day of the second week of next January when meeting week is even' do
        meeting = described_class.create!(date: Time.zone.local(2024, 12, 25), course: front_end_course)
        expect(meeting.next_date).to eq Date.new(2025, 1, 8)
      end
    end
  end

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

  describe '#notify_meeting_day' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:latest_meeting) { FactoryBot.create(:meeting, course: rails_course) }

    it 'send discord notification' do
      allow(Discord::Notifier).to receive(:message).and_return(nil)

      travel_to Time.zone.local(2024, 10, 2, 0, 30) do # 通知を送る時間を固定
        expect(latest_meeting.notified_at).to be_nil
        latest_meeting.notify_meeting_day
        expect(Discord::Notifier).to have_received(:message)
        expect(latest_meeting.notified_at).to eq Time.zone.local(2024, 10, 2, 0, 30)
      end
    end
  end
end
