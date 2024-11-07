# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Members', type: :system do
  scenario 'can access member show page' do
    rails_course = FactoryBot.create(:rails_course)
    front_end_course = FactoryBot.create(:front_end_course)
    member = FactoryBot.create(:member, course: rails_course)
    another_member = FactoryBot.create(:member, :another_member, course: front_end_course)

    login_as member
    visit member_path(member)
    expect(page).to have_selector 'h1', text: 'aliceさんの出席一覧(Railsエンジニアコース)'
    expect(page).to have_link 'チーム開発を抜ける'

    visit member_path(another_member)
    expect(page).to have_selector 'h1', text: 'bobさんの出席一覧(フロントエンドエンジニアコース)'
    expect(page).not_to have_link 'チーム開発を抜ける'
  end
end
