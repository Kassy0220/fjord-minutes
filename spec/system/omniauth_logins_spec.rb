require 'rails_helper'

RSpec.describe "OmniauthLogins", type: :system do
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
