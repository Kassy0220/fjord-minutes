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
end
