require 'rails_helper'

RSpec.describe "Attendances", type: :system do
  scenario 'not logged in user cannot access create attendance page' do
    minute = FactoryBot.create(:minute)
    visit new_minute_attendance_path(minute)

    expect(current_path).to eq root_path
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
