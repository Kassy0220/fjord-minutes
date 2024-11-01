# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { 'admin@example.com' }
    password { 'password' }
    provider { 'github' }
    uid { 123_456 }
    name { 'admin' }
    avatar_url { 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' }
  end
end
