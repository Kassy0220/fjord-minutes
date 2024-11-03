# frozen_string_literal: true

FactoryBot.define do
  factory :topic do
    trait :by_admin do
      content { '来週ミートアップがありますので、ぜひご参加を！' }
      association :minute, factory: :minute
      association :topicable, factory: :admin
    end

    trait :by_member do
      content { 'gitのブランチ履歴がおかしくなってしまったので、どなたかペアプロをお願いしたいです' }
      association :minute, factory: :minute
      association :topicable, factory: :admin
    end
  end
end
