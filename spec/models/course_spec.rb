# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  describe '#meeting_years' do
    let(:course) { FactoryBot.build(:rails_course) }

    it 'returns all years which the meeting was held' do
      FactoryBot.create(:meeting, date: Time.zone.local(2024, 1, 1), course:)
      FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course:)
      FactoryBot.create(:meeting, date: Time.zone.local(2026, 1, 1), course:)
      expect(course.meeting_years).to contain_exactly(2024, 2025, 2026)
    end
  end

  describe '#repositoory_url' do
    it 'returns GitHub repository URL for each course' do
      expect(FactoryBot.build(:rails_course).repository_url).to eq 'https://github.com/fjordllc/bootcamp'
      expect(FactoryBot.build(:front_end_course).repository_url).to eq 'https://github.com/fjordllc/agent'
    end
  end

  describe '#wiki_repository_url' do
    before do
      allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL').and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')
      allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL').and_return('https://example.com/fjordllc/agent-wiki.wiki.git')
    end

    it 'returns GitHub Wiki repository URL for each course' do
      expect(FactoryBot.build(:rails_course).wiki_repository_url).to eq 'https://example.com/fjordllc/bootcamp-wiki.wiki.git'
      expect(FactoryBot.build(:front_end_course).wiki_repository_url).to eq 'https://example.com/fjordllc/agent-wiki.wiki.git'
    end
  end

  describe '#discord_role_id' do
    before do
      allow(ENV).to receive(:fetch).with('RAILS_COURSE_SCRUM_TEAM_ROLE_ID', nil).and_return('111_111')
      allow(ENV).to receive(:fetch).with('FRONT_END_COURSE_SCRUM_TEAM_ROLE_ID', nil).and_return('222_222')
    end

    it 'returns Discord role id for each course' do
      expect(FactoryBot.build(:rails_course).discord_role_id).to eq 111_111
      expect(FactoryBot.build(:front_end_course).discord_role_id).to eq 222_222
    end
  end

  describe '#discord_webhook_url' do
    before do
      allow(ENV).to receive(:fetch).with('RAILS_COURSE_CHANNEL_URL', nil).and_return('https://discord.com/api/webhooks/111/abcdef')
      allow(ENV).to receive(:fetch).with('FRONT_END_COURSE_CHANNEL_URL', nil).and_return('https://discord.com/api/webhooks/222/ghijkl')
    end

    it 'returns Discord webhook URL for each course' do
      expect(FactoryBot.build(:rails_course).discord_webhook_url).to eq 'https://discord.com/api/webhooks/111/abcdef'
      expect(FactoryBot.build(:front_end_course).discord_webhook_url).to eq 'https://discord.com/api/webhooks/222/ghijkl'
    end
  end

  describe '#create_next_meeting_and_minute' do
    let(:rails_course) { FactoryBot.create(:rails_course) }

    context 'when create the first meeting' do
      let(:latest_meeting_date) { Date.new(2024, 11, 6) }

      before do
        # Git.cloneが実行されないようにスタブを行う
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL').and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')
        allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL').and_return('https://example.com/fjordllc/agent-wiki.wiki.git')
        allow(Git).to receive(:clone).with('https://example.com/fjordllc/bootcamp-wiki.wiki.git', Rails.root.join('bootcamp_wiki_repository')).and_return(nil)
        # クローンしたリポジトリを利用するメソッドをスタブ
        allow(rails_course).to receive_messages(get_latest_meeting_date_from_cloned_minutes: latest_meeting_date,
                                                get_next_meeting_date_from_cloned_minutes: Date.new(2024, 11, 20))
      end

      it 'create next meeting and minute' do
        allow(Discord::Notifier).to receive(:message).and_return(nil)

        travel_to latest_meeting_date.tomorrow do
          expect { rails_course.create_next_meeting_and_minute }.to change(rails_course.meetings, :count).by(1).and change(rails_course.minutes, :count).by(1)
        end
        expect(Meeting.last.date).to eq Date.new(2024, 11, 20)
      end

      it 'does not create next meeting and minute if the latest meeting is not finished' do
        number_of_minutes = rails_course.minutes.count
        travel_to latest_meeting_date do
          expect { rails_course.create_next_meeting_and_minute }.not_to change(rails_course.meetings, :count)
          expect(number_of_minutes).to eq rails_course.minutes.count
        end
      end
    end

    context 'when create the second and subsequent meeting' do
      let(:latest_meeting) { FactoryBot.create(:meeting, course: rails_course) }

      it 'create next meeting and minute' do
        allow(Discord::Notifier).to receive(:message).and_return(nil)

        travel_to latest_meeting.date.tomorrow do
          expect { rails_course.create_next_meeting_and_minute }.to change(rails_course.meetings, :count).by(1).and change(rails_course.minutes, :count).by(1)
        end
        expect(Meeting.last.date).to eq Date.new(2024, 10, 16)
      end

      it 'does not create next meeting and minute if the latest meeting is not finished' do
        number_of_minutes = rails_course.minutes.count
        travel_to latest_meeting.date do
          expect { rails_course.create_next_meeting_and_minute }.not_to change(rails_course.meetings, :count)
          expect(number_of_minutes).to eq rails_course.minutes.count
        end
      end
    end

    # 定期処理が2回実行されてしまった場合のテスト
    it 'does not create meetings with the same date' do
      allow(Discord::Notifier).to receive(:message).and_return(nil)

      latest_meeting = FactoryBot.create(:meeting, course: rails_course)
      travel_to latest_meeting.date.tomorrow do
        expect { rails_course.create_next_meeting_and_minute }.to change(rails_course.meetings, :count)
        expect { rails_course.create_next_meeting_and_minute }.not_to change(rails_course.meetings, :count)
        expect(Discord::Notifier).to have_received(:message).once
      end
    end
  end
end
