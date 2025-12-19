# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Meeting, type: :model do
  describe 'sets next_date automatically on create' do
    let(:rails_course) { FactoryBot.build(:rails_course, meeting_week: :odd) }
    let(:front_end_course) { FactoryBot.build(:front_end_course, meeting_week: :even) }

    context 'when cweek parity alternates normally' do
      it 'next_date is two weeks later' do
        rails_course_meeting = described_class.create!(date: Time.zone.local(2025, 12, 3), course: rails_course)
        expect(rails_course_meeting.date.cweek.odd?).to be true
        expect(rails_course_meeting.next_date).to eq Date.new(2025, 12, 17)
        expect(rails_course_meeting.next_date.cweek.odd?).to be true

        front_end_course_meeting = described_class.create!(date: Time.zone.local(2025, 12, 10), course: front_end_course)
        expect(front_end_course_meeting.date.cweek.even?).to be true
        expect(front_end_course_meeting.next_date).to eq Date.new(2025, 12, 24)
        expect(front_end_course_meeting.next_date.cweek.even?).to be true
      end
    end

    context 'when cweek parity alternates normally over year boundary' do
      # 一年の週数が52週ある年の場合、年を跨いでも週の偶奇が2週間で変わる
      it 'next_date is two weeks later' do
        odd_week_meeting = described_class.create!(date: Time.zone.local(2025, 12, 17), course: rails_course)
        expect(odd_week_meeting.date.cweek).to eq 51
        expect(odd_week_meeting.next_date).to eq Date.new(2025, 12, 31)
        expect(odd_week_meeting.next_date.cweek).to eq 1 # 2026/1/1 は木曜日であるため、2025/12/29-31 は2026年の1週目となる

        even_week_meeting = described_class.create!(date: Time.zone.local(2025, 12, 24), course: front_end_course)
        expect(even_week_meeting.date.cweek).to eq 52
        expect(even_week_meeting.next_date).to eq Date.new(2026, 1, 7)
        expect(even_week_meeting.next_date.cweek).to eq 2
      end
    end

    context 'when cweek parity does not alternate due to year boundary' do
      # 53週 → 1週 というように、奇数週が続く場合
      it 'next_date is a week later' do
        meeting = described_class.create!(date: Time.zone.local(2026, 12, 30), course: rails_course)
        expect(meeting.date.cweek).to eq 53
        expect(meeting.next_date).to eq Date.new(2027, 1, 6)
        expect(meeting.next_date.cweek).to eq 1
      end

      # 52週 → 53週 → 1週 → 2週というように、偶数週が3週間後になる場合
      it 'next_date is three weeks later' do
        meeting = described_class.create!(date: Time.zone.local(2026, 12, 23), course: front_end_course)
        expect(meeting.date.cweek).to eq 52
        expect(meeting.next_date).to eq Date.new(2027, 1, 13)
        expect(meeting.next_date.cweek).to eq 2
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

  describe '#scheduled_date' do
    context 'when meeting is held on odd weeks' do
      let(:course) { FactoryBot.create(:rails_course) }

      it 'correctly returns scheduled meeting dates' do
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2025, 6, 4))
        expected_dates = [Date.new(2025, 6, 18), Date.new(2025, 7, 2), Date.new(2025, 7, 16), Date.new(2025, 7, 30)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates
      end

      it 'correctly returns meeting dates that span across year' do
        # 週数が52で年を跨ぐ場合
        # 2025/12/17 (ISO週番号: 51) → 2025/12/31 (ISO週番号: 1)
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2025, 12, 17))
        expected_dates = [Date.new(2025, 12, 31), Date.new(2026, 1, 14), Date.new(2026, 1, 28), Date.new(2026, 2, 11)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates

        # 週数が53で年を跨ぐ場合
        # 2026/12/30 (ISO週番号: 53）→ 2027/1/6 (ISO週番号: 1)
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2026, 12, 30))
        expected_dates = [Date.new(2027, 1, 6), Date.new(2027, 1, 20), Date.new(2027, 2, 3), Date.new(2027, 2, 17)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates
      end
    end

    context 'when meeting is held on even weeks' do
      let(:course) { FactoryBot.create(:front_end_course) }

      it 'correctly returns scheduled meeting dates correctly' do
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2025, 6, 11))
        expected_dates = [Date.new(2025, 6, 25), Date.new(2025, 7, 9), Date.new(2025, 7, 23), Date.new(2025, 8, 6)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates
      end

      it 'correctly returns meeting dates that span across year' do
        # 週数が52で年を跨ぐ場合
        # 2025/12/24 (ISO週番号: 52) → 2026/1/7 (ISO週番号: 2)
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2025, 12, 24))
        expected_dates = [Date.new(2026, 1, 7), Date.new(2026, 1, 21), Date.new(2026, 2, 4), Date.new(2026, 2, 18)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates

        # 週数が53で年を跨ぐ場合
        # 2026/12/23 (ISO週番号: 52）→ 2027/1/13 (ISO週番号: 2)
        meeting = FactoryBot.create(:meeting, course:, date: Date.new(2026, 12, 23))
        expected_dates = [Date.new(2027, 1, 13), Date.new(2027, 1, 27), Date.new(2027, 2, 10), Date.new(2027, 2, 24)]
        expect(meeting.scheduled_dates(limit: 4)).to eq expected_dates
      end
    end
  end
end
