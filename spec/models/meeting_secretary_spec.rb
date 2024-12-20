# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingSecretary, type: :model do
  describe '#create_minute' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:latest_minute) { FactoryBot.create(:minute, next_meeting_date: Time.zone.local(2024, 11, 20), course: rails_course) }
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
      # CI上でリポジトリのwikiのURLを参照した際にエラーが発生しないように、適当な値を返すようにする
      allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL', nil).and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')

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
      # GithubWikiManager.new が呼ばれると Git.clone が実行されてしまい困るため、、newメソッドをスタブする
      github_wiki_manager_double = instance_double(GithubWikiManager)
      allow(GithubWikiManager).to receive(:new).and_return(github_wiki_manager_double)
      allow(github_wiki_manager_double).to receive(:working_directory).and_return(Rails.root.join('stubbed_repository'))
      # クローンしたリポジトリを利用するメソッドをスタブ
      allow(meeting_secretary).to receive_messages(get_latest_meeting_date_from_cloned_minutes: latest_meeting_date,
                                                   get_next_meeting_date_from_cloned_minutes: Time.zone.local(2024, 11, 20))
      # Discord通知が行われないようにスタブ
      allow(Discord::Notifier).to receive(:message).and_return(nil)
    end

    it 'create minute of next meeting' do
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
        expect(Discord::Notifier).to have_received(:message).once
      end
    end
  end

  describe '#notify_today_meeting' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:latest_minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:meeting_secretary) { described_class.new(rails_course) }

    before do
      allow(Discord::Notifier).to receive(:message).and_return(nil)
    end

    it 'send discord notification' do
      travel_to latest_minute.meeting_date do
        meeting_secretary.notify_today_meeting
        expect(Discord::Notifier).to have_received(:message)
      end
    end

    it 'does not send notification when there is not minute' do
      meeting_secretary.notify_today_meeting
      expect(Discord::Notifier).not_to have_received(:message)
    end

    it 'does not send notification when today is not meeting date' do
      travel_to latest_minute.meeting_date - 1.day do
        meeting_secretary.notify_today_meeting
        expect(Discord::Notifier).not_to have_received(:message)
      end
    end

    it 'does not send notification when notification is already sent' do
      travel_to latest_minute.meeting_date do
        meeting_secretary.notify_today_meeting
        meeting_secretary.notify_today_meeting
        expect(Discord::Notifier).to have_received(:message).once
      end
    end
  end
end
