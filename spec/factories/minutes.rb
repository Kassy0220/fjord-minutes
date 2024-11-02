# frozen_string_literal: true

FactoryBot.define do
  factory :minute do
    release_branch { 'https://example.com/fjordllc/bootcamp/pull/1000' }
    release_note { 'https://example.com/announcements/100' }
    other { '連絡事項は特にありません' }
    meeting_date { Time.zone.local(2024, 10, 2) }
    next_meeting_date { Time.zone.local(2024, 10, 16) }
    notified_at { nil }
    exported { false }
    association :course, factory: :rails_course
  end
end
