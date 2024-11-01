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
  end
end
