# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    email { 'alice@example.com' }
    password { 'password' }
    provider { 'github' }
    uid { 111_111 }
    name { 'alice' }
    avatar_url { 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' }
    association :course, factory: :rails_course

    trait :another_member do
      email { 'bob@example.com' }
      uid { 222_222 }
      name { 'bob' }
    end

    trait :absent_member do
      email { 'absentee@example.com' }
      uid { 333_333 }
      name { 'absentee' }
    end

    trait :unexcused_absent_member do
      email { 'unexcused_absentee@example.com' }
      uid { 444_444 }
      name { 'unexcused_absentee' }
    end

    trait :sample_member do
      sequence(:email) { |n| "member-#{n}@example.com" }
      sequence(:uid) { |n| n }
      sequence(:name) { |n| "member-#{n}" }
    end
  end
end
