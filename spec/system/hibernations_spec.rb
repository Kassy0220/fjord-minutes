# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Hibernations', type: :system do
  let(:rails_course) { FactoryBot.create(:rails_course) }
  let(:member) { FactoryBot.create(:member, course: rails_course) }

  before do
    login_as member
  end

  scenario 'member can hibernate and return from hibernation', :js do
    visit root_path
    expect(page).to have_button 'チーム開発を抜ける'
    expect(member.hibernated?).to be false

    page.accept_confirm do
      click_button 'チーム開発を抜ける'
    end
    expect(current_path).to eq root_path
    expect(page).to have_content 'ログアウトしました'
    expect(member.reload.hibernated?).to be true

    find('button', text: "Railsエンジニア\nコースで登録").click
    expect(page).to have_content 'チーム開発に復帰しました。'
    expect(member.reload.hibernated?).to be false
  end

  scenario 'hibernated member cannot access application and must login again' do
    FactoryBot.create(:hibernation, member:)

    visit course_members_path(rails_course)
    expect(current_path).to eq root_path
    expect(page).to have_content 'チームメンバーから外れているため、再度ログインをお願いします。'
    expect(page).not_to have_content 'aliceさんの出席一覧(Railsエンジニアコース)'
    expect(page).to have_selector 'button', text: "Railsエンジニア\nコースで登録"
  end
end
