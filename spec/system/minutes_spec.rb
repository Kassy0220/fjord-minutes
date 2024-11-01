# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes', type: :system do
  context 'when as admin' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:admin) { FactoryBot.create(:admin) }

    before do
      login_as_admin admin
    end

    it 'can access all edit form', :js do
      visit edit_minute_path(minute)
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
