# frozen_string_literal: true

FactoryBot.define do
  factory :rails_course, class: 'Course' do
    name { 'Railsエンジニアコース' }
    meeting_week { 0 }
    kind { 0 }
  end

  factory :front_end_course, class: 'Course' do
    name { 'フロントエンドエンジニアコース' }
    meeting_week { 1 }
    kind { 1 }
  end
end
