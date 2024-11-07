# frozen_string_literal: true

FactoryBot.define do
  factory :hibernation do
    finished_at { nil }
    association :member, factory: :member
  end
end
