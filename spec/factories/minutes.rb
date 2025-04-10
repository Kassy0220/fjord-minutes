# frozen_string_literal: true

FactoryBot.define do
  factory :minute do
    release_branch { 'https://example.com/fjordllc/bootcamp/pull/1000' }
    release_note { 'https://example.com/announcements/100' }
    other { '連絡事項は特にありません' }
    exported { false }
    association :meeting, factory: :meeting
  end
end
