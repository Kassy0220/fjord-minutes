# frozen_string_literal: true

FactoryBot.define do
  factory :meeting do
    date { Time.zone.local(2024, 10, 2) }
    # next_date属性はモデル作成時に自動で日付がセットされるため、Factory内では指定しない
    notified_at { nil }
    association :course, factory: :rails_course
  end
end
