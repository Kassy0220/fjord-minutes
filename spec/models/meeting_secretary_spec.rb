# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeetingSecretary, type: :model do
  describe '.prepare_for_meeting' do
    it 'create minute and notify today meeting for all course' do
      rails_course = FactoryBot.create(:rails_course)
      front_end_course = FactoryBot.create(:front_end_course)

      # MeetingSecretary#create_first_minuteと#notify_today_meetingが実行されると外部にリクエストが送られてしまうため、モック化しておく
      rails_course_meeting_secretary = instance_double(described_class)
      allow(rails_course_meeting_secretary).to receive_messages(create_first_minute: nil, notify_today_meeting: nil)
      front_end_course_meeting_secretary = instance_double(described_class)
      allow(front_end_course_meeting_secretary).to receive_messages(create_first_minute: nil, notify_today_meeting: nil)

      allow(described_class).to receive(:new).with(rails_course).and_return(rails_course_meeting_secretary)
      allow(described_class).to receive(:new).with(front_end_course).and_return(front_end_course_meeting_secretary)

      described_class.prepare_for_meeting

      expect(rails_course_meeting_secretary).to have_received(:create_first_minute)
      expect(rails_course_meeting_secretary).to have_received(:notify_today_meeting)
      expect(front_end_course_meeting_secretary).to have_received(:create_first_minute)
      expect(front_end_course_meeting_secretary).to have_received(:notify_today_meeting)
    end
  end

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
      # MinuteGithubExporter.new が呼ばれると Git.clone が実行されてしまい困るため、newメソッドをスタブする
      github_wiki_manager_double = instance_double(MinuteGithubExporter)
      allow(MinuteGithubExporter).to receive(:new).and_return(github_wiki_manager_double)
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
