# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Course.find_or_create_by!(name: 'Railsエンジニアコース') do |course|
  course.meeting_week = :odd
end

Course.find_or_create_by!(name: 'フロントエンドエンジニアコース') do |course|
  course.meeting_week = :even
end
