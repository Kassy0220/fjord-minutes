# frozen_string_literal: true

FactoryBot.define do
  factory :meeting do
    date { Time.zone.local(2024, 10, 2) }
    next_date { Time.zone.local(2024, 10, 16) }
    notified_at { nil }
    association :course, factory: :rails_course
  end
end
