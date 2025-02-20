# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  describe '#meeting_years' do
    let(:course) { FactoryBot.build(:rails_course) }

    it 'returns all years which the meeting was held' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 1), course:)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course:)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2026, 1, 1), course:)
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
      allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL', nil).and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')
      allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL', nil).and_return('https://example.com/fjordllc/agent-wiki.wiki.git')
    end

    it 'returns GitHub Wiki repository URL for each course' do
      expect(FactoryBot.build(:rails_course).wiki_repository_url).to eq 'https://example.com/fjordllc/bootcamp-wiki.wiki.git'
      expect(FactoryBot.build(:front_end_course).wiki_repository_url).to eq 'https://example.com/fjordllc/agent-wiki.wiki.git'
    end
  end
end
