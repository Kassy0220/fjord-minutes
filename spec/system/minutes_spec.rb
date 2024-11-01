# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes', type: :system do
  context 'when as admin' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:admin) { FactoryBot.create(:admin) }

    before do
      login_as_admin admin
      visit edit_minute_path(minute)
    end

    it 'can access all edit form', :js do
      within('#release_branch_form') do
        expect(page).to have_selector 'button', text: '編集'
      end
      within('#release_note_form') do
        expect(page).to have_selector 'button', text: '編集'
      end
      within('#topics') do
        expect(page).to have_selector 'button', text: '作成'
      end
      within('#other_form') do
        expect(page).to have_selector 'textarea'
        expect(page).to have_selector 'button', text: '更新'
      end
      within('#next_meeting_date_form') do
        expect(page).to have_selector 'button', text: '編集'
      end
    end

    it 'can edit release branch and release note', :js do
      within('#release_branch_form') do
        expect(page).to have_content 'https://example.com/fjordllc/bootcamp/pull/1000'

        click_button '編集'
        fill_in 'release_branch_field', with: 'https://example.com/fjordllc/bootcamp/pull/9999'
        click_button '更新'
        expect(page).not_to have_selector 'input'
        expect(page).to have_content 'https://example.com/fjordllc/bootcamp/pull/9999'
      end

      within('#release_note_form') do
        expect(page).to have_content 'https://example.com/announcements/100'

        click_button '編集'
        fill_in 'release_note_field', with: 'https://example.com/fjordllc/bootcamp/pull/999'
        click_button '更新'
        expect(page).not_to have_selector 'input'
        expect(page).to have_content 'https://example.com/fjordllc/bootcamp/pull/999'
      end
    end

    it 'can edit other', :js do
      within('#other_form') do
        expect(page).to have_selector 'textarea', text: '連絡事項は特にありません'
        fill_in 'other_field', with: '次のリリースは午前中に行いますのでご注意ください'
        click_button '更新'
      end
      expect(page).to have_content '次のリリースは午前中に行いますのでご注意ください' # 非同期で議事録の更新が行われるまで待つ
      expect(minute.reload.other).to eq '次のリリースは午前中に行いますのでご注意ください'
    end

    it 'can edit next meeting date', :js do
      within('#next_meeting_date_form') do
        expect(page).to have_content '2024年10月16日'

        click_button '編集'
        # 日付編集フォームの実装はflowbite-reactのDatepickerを使っているが、このコンポーネントは<input type="text">を返すようになっている
        # 以下の手順で日付編集フォームを操作することができたので、一旦以下の方法でテストを実装する
        # fill_in で日付編集フォームの日付選択欄を開く
        # click_buttonで日付を選択する
        fill_in 'next_meeting_date_field', with: Date.new(2024, 10, 23)
        click_button '23日'
        click_button '更新'
        expect(page).not_to have_selector 'input'
        expect(page).to have_content '2024年10月23日'
      end
    end
  end

  context 'when as member' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    it 'can access only topic edit form', :js do
      visit edit_minute_path(minute)
      within('#release_branch_form') do
        expect(page).not_to have_selector 'button', text: '編集'
      end
      within('#release_note_form') do
        expect(page).not_to have_selector 'button', text: '編集'
      end
      within('#topics') do
        expect(page).to have_selector 'button', text: '作成'
      end
      within('#other_form') do
        expect(page).not_to have_selector 'textarea'
        expect(page).not_to have_selector 'button', text: '更新'
      end
      within('#next_meeting_date_form') do
        expect(page).not_to have_selector 'button', text: '編集'
      end
    end
  end
end
