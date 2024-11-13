# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OmniauthLogins', type: :system do
  before do
    FactoryBot.create(:rails_course)
    FactoryBot.create(:front_end_course)
  end

  context 'when as a member' do
    before do
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:member]
      OmniAuth.config.add_mock(:github, { uid: '123456',
                                          info: { nickname: 'alice',
                                                  email: 'alice@example.com',
                                                  image: 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' } })
    end

    scenario 'user can log in as member of the Rails course' do
      visit root_path
      click_button 'Railsエンジニアコースで登録'

      expect(page).to have_content 'GitHub アカウントによる認証に成功しました。'
      expect(page).to have_selector 'h1', text: 'aliceさんの出席一覧(Railsエンジニアコース)'
    end

    scenario 'user can log in as member of the front end course' do
      visit root_path
      click_button 'フロントエンドエンジニアコースで登録'

      expect(page).to have_content 'GitHub アカウントによる認証に成功しました。'
      expect(page).to have_selector 'h1', text: 'aliceさんの出席一覧(フロントエンドエンジニアコース)'
    end
  end

  context 'when as an admin' do
    before do
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:member]
      OmniAuth.config.add_mock(:github, { uid: '123456',
                                          info: { nickname: 'kassy0220',
                                                  email: 'kassy0220@example.com',
                                                  image: 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' } })

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('KASSY_EMAIL', 'no_email').and_return('kassy0220@example.com')
    end

    scenario 'user can log in as admin' do
      visit root_path
      click_button 'Railsエンジニアコースで登録'

      expect(page).to have_content 'GitHub アカウントによる認証に成功しました。'
      expect(page).to have_content '管理者用のダッシュボード'
      expect(page).to have_content '名前 : kassy0220'
    end
  end

  context 'when failure login' do
    before do
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:member]
      OmniAuth.config.mock_auth[:github] = :invalid_credentials
    end

    scenario 'redirect root page when login fails' do
      visit root_path
      click_button 'Railsエンジニアコースで登録'

      expect(current_path).to eq root_path
      expect(page).to have_content 'GitHub アカウントによる認証に失敗しました。'
    end
  end
end
