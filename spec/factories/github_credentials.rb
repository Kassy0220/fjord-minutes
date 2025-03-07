# frozen_string_literal: true

FactoryBot.define do
  factory :github_credential do
    access_token { 'abcdef' }
    refresh_token { 'ghijkl' }
    expires_at { Time.zone.local(2025, 2, 1, 12) }
    association :admin, factory: :admin
  end
end
