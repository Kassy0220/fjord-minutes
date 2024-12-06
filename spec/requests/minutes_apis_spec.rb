# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes API', type: :request do
  let!(:minute) { FactoryBot.create(:minute) }
  let(:admin) { FactoryBot.create(:admin) }

  context 'when update minute' do
    it 'broadcast to subscriber when minute is updated' do
      sign_in admin
      expect do
        patch api_minute_path(minute), params: { id: minute.id, minute: { release_branch: 'http://example.com/pull/1234' } }
      end.to have_broadcasted_to(minute).from_channel(MinuteChannel)
    end
  end
end
