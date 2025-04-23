# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    attended { true }
    session { :afternoon }
    absence_reason { nil }
    progress_report { nil }
    association :member, factory: :member
    association :meeting, factory: :meeting

    trait :night do
      session { :night }
    end

    trait :absence do
      attended { false }
      session { nil }
      absence_reason { '体調不良のため。' }
      progress_report { 'PRのチームメンバーのレビューが通り、komagataさんにレビュー依頼をお願いしているところです。' }
    end

    trait :absence_with_multiple_progress_reports do
      attended { false }
      session { nil }
      absence_reason { '職場のイベントに参加するため。' }
      progress_report { "#8000 チームメンバーにレビュー依頼を行いました。\r\n#8102 問題が発生している箇所の調査を行いました(関連Issue#8100)。\r\n#8080 依頼されたレビュー対応を行いました。" }
    end
  end
end
