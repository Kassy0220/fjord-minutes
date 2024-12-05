# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinuteChannel, type: :channel do
  it 'successfully subscribes with minute id' do
    minute = FactoryBot.create(:minute)
    subscribe id: minute.id

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(minute)
  end

  it 'does not subscribe without minute id' do
    expect { subscribe }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
