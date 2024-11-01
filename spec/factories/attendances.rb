# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    status { :present }
    time { :day }
    absence_reason { nil }
    progress_report { nil }
    association :member, factory: :member
    association :minute, factory: :minute

    trait :night do
      time { :night }
    end

    trait :absence do
      status { :absent }
      time { nil }
      absence_reason { '体調不良のため。' }
      progress_report { 'PRのチームメンバーのレビューが通り、komagataさんにレビュー依頼をお願いしているところです。' }
    end
  end
end
