# frozen_string_literal: true

FactoryBot.define do
  factory :minute do
    release_branch { '' }
    release_note { '' }
    other { '' }
    meeting_date { Time.zone.local(2024, 10, 2) }
    next_meeting_date { Time.zone.local(2024, 10, 16) }
    notified_at { nil }
    association :course, factory: :rails_course
  end
end
