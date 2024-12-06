# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes API', type: :request do
  let!(:minute) { FactoryBot.create(:minute) }
  let(:admin) { FactoryBot.create(:admin) }

  context 'when update minute' do
    it 'update minute successfully' do
      sign_in admin
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { release_branch: 'https://example.com/pull/1234' } }
      end.to change { Minute.find(minute.id).release_branch }.from('https://example.com/fjordllc/bootcamp/pull/1000').to('https://example.com/pull/1234')
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { release_note: 'https://example.com/announcements/999' } }
      end.to change { Minute.find(minute.id).release_note }.from('https://example.com/announcements/100').to('https://example.com/announcements/999')
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { other: '来週のミーティングはお休みです' } }
      end.to change { Minute.find(minute.id).other }.from('連絡事項は特にありません').to('来週のミーティングはお休みです')
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { next_meeting_date: Date.new(2024, 11, 6) } }
      end.to change { Minute.find(minute.id).next_meeting_date }.from(Date.new(2024, 10, 16)).to(Date.new(2024, 11, 6))
    end

    it 'broadcast to subscriber when minute is updated' do
      broadcasted_data = { release_branch: 'https://example.com/pull/1234', release_note: 'https://example.com/announcements/100', other: '連絡事項は特にありません',
                           next_meeting_date: '2024-10-16' }.as_json
      sign_in admin
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { release_branch: 'https://example.com/pull/1234' } }
      end.to have_broadcasted_to(minute).from_channel(MinuteChannel).with(body: { minute: broadcasted_data })
    end
  end
end
