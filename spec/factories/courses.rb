FactoryBot.define do
  factory :rails_course, class: 'Course' do
    name { 'Railsエンジニアコース' }
    meeting_week { 0 }
  end

  factory :front_end_course, class: 'Course' do
    name { 'フロントエンドエンジニアコース' }
    meeting_week { 1 }
  end
end
