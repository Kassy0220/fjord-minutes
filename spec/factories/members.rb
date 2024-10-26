FactoryBot.define do
  factory :member do
    email { 'alice@example.com' }
    password { 'password' }
    provider { 'github' }
    uid { 111111 }
    name { 'alice' }
    avatar_url { 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' }
    association :course, factory: :rails_course
  end
end
