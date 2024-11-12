# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :system do
  scenario 'user can access top page' do
    FactoryBot.create(:rails_course)
    FactoryBot.create(:front_end_course)

    visit root_path
    expect(page).to have_content 'Fjord Minutes'
    expect(page).to have_button 'Railsエンジニアコースでログイン'
    expect(page).to have_button 'フロントエンドエンジニアコースでログイン'
  end

  scenario 'header content changes whether the member logged in' do
    member = FactoryBot.create(:member)

    visit root_path
    within('nav#header') do
      expect(page).to have_link 'Fjord Minutes', href: root_path
      expect(page).not_to have_link '議事録', href: course_minutes_path(member.course)
      expect(page).not_to have_link 'メンバー', href: course_members_path(member.course)
      expect(page).not_to have_selector("img[src$='#{member.avatar_url}']")
    end

    login_as member
    visit root_path
    within('nav#header') do
      expect(page).to have_link 'Fjord Minutes', href: root_path
      expect(page).to have_link '議事録', href: course_minutes_path(member.course)
      expect(page).to have_link 'メンバー', href: course_members_path(member.course)
      expect(page).to have_selector("img[src$='#{member.avatar_url}']")
    end
  end
end
