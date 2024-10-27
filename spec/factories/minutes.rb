FactoryBot.define do
  factory :minute do
    release_branch { '' }
    release_note { '' }
    other { '' }
    meeting_date { Date.new(2024, 10, 02) }
    next_meeting_date { Date.new(2024, 10, 16) }
    notified_at { nil }
    association :course, factory: :rails_course
  end
end