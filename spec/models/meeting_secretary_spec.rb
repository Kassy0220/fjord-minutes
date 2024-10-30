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

  describe '#create_first_minute' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:meeting_secretary) { described_class.new(rails_course) }
    let(:latest_meeting_date) { Date.new(2024, 11, 6) }

    before do
      allow(meeting_secretary).to receive_messages(get_latest_meeting_date_from_cloned_minutes: latest_meeting_date,
                                                   get_next_meeting_date_from_cloned_minutes: Date.new(2024, 11, 20))
    end

    it 'create minute of next meeting' do
      allow(Discord::Notifier).to receive(:message).and_return(nil)

      travel_to latest_meeting_date + 1.day do
        expect { meeting_secretary.create_first_minute }.to change(rails_course.minutes, :count).by(1)
        expect(Discord::Notifier).to have_received(:message)
      end

      created_minute = rails_course.minutes.last
      expect(created_minute.meeting_date).to eq Date.new(2024, 11, 20)
      expect(created_minute.next_meeting_date).to eq Date.new(2024, 12, 4)
    end

    it 'does not create minute if latest meeting is not finished' do
      travel_to latest_meeting_date do
        expect { meeting_secretary.create_first_minute }.not_to change(rails_course.minutes, :count)
      end
    end

    # 定期処理が2回実行されてしまった場合のテスト
    it 'does not create multiple minutes with the same meeting date' do
      travel_to latest_meeting_date + 1.day do
        expect { meeting_secretary.create_first_minute }.to change(rails_course.minutes, :count).by(1)
        expect { meeting_secretary.create_first_minute }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
