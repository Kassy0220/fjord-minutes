# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :system do
  scenario 'user can access top page' do
    FactoryBot.create(:rails_course)
    FactoryBot.create(:front_end_course)

    visit root_path
    expect(page).to have_selector 'h1', text: "フィヨルドブートキャンプのチーム開発プラクティスで行われるミーティングを\n議事録の自動作成と出席管理でより効率的に"
    expect(page).to have_button 'Railsエンジニアコースで登録'
    expect(page).to have_button 'フロントエンドエンジニアコースで登録'
  end

  context 'with header' do
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
end
