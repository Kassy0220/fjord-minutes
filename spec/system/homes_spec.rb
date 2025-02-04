# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :system do
  scenario 'user can access top page' do
    FactoryBot.create(:rails_course)
    FactoryBot.create(:front_end_course)

    visit root_path
    expect(page).to have_selector 'h1', text: "FBCチーム開発プラクティスの\n議事録の作成と出席管理ツール"
    expect(page).to have_button 'Railsエンジニアコースで登録'
    expect(page).to have_button 'フロントエンドエンジニアコースで登録'
  end

  context 'with header' do
    scenario 'header content changes whether the member logged in' do
      member = FactoryBot.create(:member)

      visit root_path
      within('nav#header') do
        expect(page).to have_selector('img[alt="Fjord Minutesのロゴ画像"]')
        expect(page).not_to have_link '議事録', href: course_minutes_path(member.course)
        expect(page).not_to have_link 'メンバー', href: course_members_path(member.course)
        expect(page).not_to have_selector("img[src$='#{member.avatar_url}']")
      end

      login_as member
      visit root_path
      within('nav#header') do
        expect(page).to have_selector('img[alt="Fjord Minutesのロゴ画像"]')
        expect(page).to have_link '議事録', href: course_minutes_path(member.course)
        expect(page).to have_link 'メンバー', href: course_members_path(member.course)
        expect(page).to have_selector("img[src$='#{member.avatar_url}']")
      end
    end

    scenario "admin's header displays the links to first course minutes and first course members" do
      first_course = FactoryBot.create(:rails_course)
      second_course = FactoryBot.create(:front_end_course)
      admin = FactoryBot.create(:admin)
      login_as_admin admin
      within('nav#header') do
        expect(page).to have_link '議事録', href: course_minutes_path(first_course)
        expect(page).to have_link 'メンバー', href: course_members_path(first_course)
        expect(page).not_to have_link '議事録', href: course_minutes_path(second_course)
        expect(page).not_to have_link 'メンバー', href: course_members_path(second_course)
      end
    end
  end

  scenario 'admin dashboard displays the course details' do
    rails_course = FactoryBot.create(:rails_course)
    front_end_course = FactoryBot.create(:front_end_course)
    FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course)
    rails_course_latest_minute = FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 16), course: rails_course)
    FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 9), course: front_end_course)
    front_end_course_latest_minute = FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 23), course: front_end_course)

    admin = FactoryBot.create(:admin)
    login_as_admin admin
    visit root_path

    within("div[data-course='#{rails_course.id}']") do
      expect(page).to have_link '議事録一覧', href: course_minutes_path(rails_course)
      expect(page).to have_link 'メンバー一覧', href: course_members_path(rails_course)
      expect(page).to have_content '奇数週 (第一・第三週)'
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月16日', href: edit_minute_path(rails_course_latest_minute)
    end
    within("div[data-course='#{front_end_course.id}']") do
      expect(page).to have_link '議事録一覧', href: course_minutes_path(front_end_course)
      expect(page).to have_link 'メンバー一覧', href: course_members_path(front_end_course)
      expect(page).to have_content '偶数週 (第二・第四週)'
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月23日', href: edit_minute_path(front_end_course_latest_minute)
    end
  end

  scenario 'user can access privacy policy' do
    visit pp_path
    expect(page).to have_selector 'h1', text: 'プライバシーポリシー'
  end

  scenario 'user can access terms of service' do
    visit terms_of_service_path
    expect(page).to have_selector 'h1', text: '利用規約'
  end

  scenario 'footer contains privacy policy, terms of service, repository link, and copyright' do
    visit root_path
    expect(page).to have_selector 'footer'
    within('footer') do
      expect(page).to have_link '利用規約', href: terms_of_service_path
      expect(page).to have_link 'プライバシーポリシー', href: pp_path
      expect(page).to have_link href: 'https://github.com/Kassy0220/fjord-minutes'
      expect(page).to have_selector 'span', text: '© 2024 Kassy0220'
    end
  end
end
