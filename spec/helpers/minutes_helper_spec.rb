# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinutesHelper, type: :helper do
  describe '#github_wiki_url' do
    before do
      allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL', nil).and_return('https://example.com/fjordllc/bootcamp.wiki.git')
      allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL', nil).and_return('https://example.com/fjordllc/agent.wiki.git')
    end

    it 'returns minute url on GitHub Wiki' do
      rails_course = FactoryBot.create(:rails_course)
      rails_course_minute = FactoryBot.create(:minute, course: rails_course)
      url_encoded_minute_title = URI.encode_www_form_component(rails_course_minute.title)
      expect(helper.github_wiki_url(rails_course_minute)).to eq "https://example.com/fjordllc/bootcamp/wiki/#{url_encoded_minute_title}"

      front_end_course = FactoryBot.create(:front_end_course)
      front_end_course_minute = FactoryBot.create(:minute, course: front_end_course)
      url_encoded_minute_title = URI.encode_www_form_component(front_end_course_minute.title)
      expect(helper.github_wiki_url(front_end_course_minute)).to eq "https://example.com/fjordllc/agent/wiki/#{url_encoded_minute_title}"
    end
  end
end
