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
    expect(page).to have_selector 'button.open_modal', text: 'チーム開発を抜ける'
    expect(member.hibernated?).to be false

    click_button 'チーム開発を抜ける'
    choose 'フィヨルドブートキャンプを休会することに伴い、チーム開発をお休みするため'
    find('#accept_modal').click
    expect(current_path).to eq root_path
    expect(page).to have_content 'ログアウトしました'
    expect(member.reload.hibernated?).to be true

    click_button 'Railsエンジニアコースで登録'
    expect(page).to have_content 'チーム開発に復帰しました。'
    expect(member.reload.hibernated?).to be false
  end

  scenario 'hibernated member cannot access application and must login again' do
    FactoryBot.create(:hibernation, member:)

    visit course_members_path(rails_course)
    expect(current_path).to eq root_path
    expect(page).to have_content 'チームメンバーから外れているため、再度ログインをお願いします。'
    expect(page).not_to have_content 'aliceさんの出席一覧(Railsエンジニアコース)'
    expect(page).to have_button 'Railsエンジニアコースで登録'
  end

  scenario 'member can logout as having completed the team development' do
    expect(member.completed_at).to be_nil

    visit root_path
    click_button 'チーム開発を抜ける'
    choose 'チーム開発を修了したため'
    find('#accept_modal').click
    expect(member.reload.completed_at).to eq Time.zone.today
  end
end
