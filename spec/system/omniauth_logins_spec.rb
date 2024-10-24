require 'rails_helper'

RSpec.describe "OmniauthLogins", type: :system do
  context 'as a member' do
    before do
      FactoryBot.create(:rails_course)
      FactoryBot.create(:front_end_course)

      OmniAuth.config.add_mock(:github, { uid: '123456',
                                          info: { nickname: 'alice',
                                                  email: 'alice@example.com',
                                                  image: 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' } })
    end

    scenario 'user can log in as member of the Rails course' do
      visit root_path
      click_button 'Railsエンジニアコースでログイン'

      expect(page).to have_content 'Successfully authenticated from GitHub account.'
      expect(page).to have_content 'aliceのページ'
      expect(page).to have_content '所属コース : Railsエンジニアコース'
      expect(page).to have_selector("img[src$='https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3']")
    end

    scenario 'user can log in as member of the front end course' do
      visit root_path
      click_button 'フロントエンドエンジニアコースでログイン'

      expect(page).to have_content 'Successfully authenticated from GitHub account.'
      expect(page).to have_content '所属コース : フロントエンドエンジニアコース'
    end
  end

  context 'as an admin' do
    before do
      FactoryBot.create(:rails_course)
      FactoryBot.create(:front_end_course)

      OmniAuth.config.add_mock(:github, { uid: '123456',
                                          info: { nickname: 'kassy0220',
                                                  email: 'kassy0220@example.com',
                                                  image: 'https://gyazo.com/40600d4c2f36e6ec49ec17af0ef610d3' } })

      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('KASSY_EMAIL', 'no_email').and_return('kassy0220@example.com')
    end

    scenario 'user can log in as admin' do
      visit root_path
      click_button 'Railsエンジニアコースでログイン'

      expect(page).to have_content 'Successfully authenticated from GitHub account.'
      expect(page).to have_content '管理者用のダッシュボード'
      expect(page).to have_content '管理者名 : kassy0220'
    end
  end

  context 'failure login' do
    before do
      FactoryBot.create(:rails_course)
      FactoryBot.create(:front_end_course)

      Rails.application.env_config['devise.mapping'] = Devise.mappings[:member]
      OmniAuth.config.mock_auth[:github] = :invalid_credentials
    end

    scenario 'redirect root page when login fails' do
      visit root_path
      click_button 'Railsエンジニアコースでログイン'

      expect(current_path).to eq root_path
      expect(page).to have_content 'Could not authenticate you from GitHub'
    end
  end
end
