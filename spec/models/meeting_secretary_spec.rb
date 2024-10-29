# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingSecretary, type: :model do
  describe '#create_minute' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:latest_minute) { FactoryBot.create(:minute, next_meeting_date: Date.new(2024, 11, 20), course: rails_course) }
    let(:meeting_secretary) { described_class.new(rails_course) }

    it 'create minute of next meeting' do
      allow(Discord::Notifier).to receive(:message).and_return(nil)

      travel_to latest_minute.meeting_date + 1.day do
        expect { meeting_secretary.create_minute }.to change(rails_course.minutes, :count).by(1)
        expect(Discord::Notifier).to have_received(:message)
      end

      created_minute = rails_course.minutes.last
      expect(created_minute.meeting_date).to eq Date.new(2024, 11, 20)
      expect(created_minute.next_meeting_date).to eq Date.new(2024, 12, 4)
    end

    it 'does not create minute if latest meeting is not finished' do
      travel_to latest_minute.meeting_date do
        expect { meeting_secretary.create_minute }.not_to change(rails_course.minutes, :count)
      end
    end
  end
end
