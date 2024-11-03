# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes', type: :system do
  include MinutesHelper

  context 'when edit the minutes' do
    context 'when as admin' do
      let!(:rails_course) { FactoryBot.create(:rails_course) }
      let(:minute) { FactoryBot.create(:minute, course: rails_course) }
      let(:admin) { FactoryBot.create(:admin) }

      before do
        login_as_admin admin
        visit edit_minute_path(minute)
      end

      scenario 'can access all edit form', :js do
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

      scenario 'can edit release branch and release note', :js do
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

      scenario 'can create, edit and delete topic', :js do
        within('#topics') do
          expect(find('button', text: '作成')).to be_disabled
          fill_in 'new_topic_field', with: '今週ミートアップがありますのでぜひご参加を！'
          click_button '作成'
          expect(page).to have_selector 'li', text: '今週ミートアップがありますのでぜひご参加を！(admin)'
          expect(page).to have_selector 'button', text: '編集'
          expect(page).to have_selector 'button', text: '削除'

          click_button '編集'
          fill_in 'edit_topic_field', with: 'Issueが完了したら必ずcloseするようにしましょう'
          click_button '更新'
          expect(page).to have_selector 'li', text: 'Issueが完了したら必ずcloseするようにしましょう(admin)'

          click_button '削除'
          expect(page).not_to have_selector 'li', text: 'Issueが完了したら必ずcloseするようにしましょう(admin)'
        end
      end

      scenario 'can edit other', :js do
        within('#other_form') do
          expect(page).to have_selector 'textarea', text: '連絡事項は特にありません'
          fill_in 'other_field', with: '次のリリースは午前中に行いますのでご注意ください'
          click_button '更新'
        end
        expect(page).to have_content '次のリリースは午前中に行いますのでご注意ください' # 非同期で議事録の更新が行われるまで待つ
        expect(minute.reload.other).to eq '次のリリースは午前中に行いますのでご注意ください'
      end

      scenario 'can edit next meeting date', :js do
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

      scenario 'can access only topic edit form', :js do
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

    context 'when topic form' do
      let!(:rails_course) { FactoryBot.create(:rails_course) }
      let(:minute) { FactoryBot.create(:minute, course: rails_course) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }
      let(:another_member) { FactoryBot.create(:member, :another_member, course: rails_course) }

      before do
        login_as another_member
      end

      scenario 'cannot edit and destroy topic created by others', :js do
        minute.topics.create(content: 'テストが通らないのでどなたかペアプロをお願いします！', topicable: member)

        visit edit_minute_path(minute)
        within('#topics') do
          expect(page).to have_selector 'li', text: 'テストが通らないのでどなたかペアプロをお願いします！(alice)'
          expect(page).not_to have_selector 'button', text: '編集'
          expect(page).not_to have_selector 'button', text: '削除'
        end
      end
    end

    context 'when next meeting date form' do
      let!(:rails_course) { FactoryBot.create(:rails_course) }
      let(:minute) { FactoryBot.create(:minute, next_meeting_date: Time.zone.local(2024, 10, 14), course: rails_course) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }

      before do
        login_as member
        visit edit_minute_path(minute)
      end

      scenario 'display message when next meeting is holiday' do
        within('#next_meeting_date_form') do
          expect(page).to have_content '2024年10月14日'
          expect(page).to have_content '次回開催日はスポーツの日です。もしミーティングをお休みにする場合は、開催日を変更しましょう。'
        end
      end
    end
  end

  context 'when list the minutes' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:front_end_course) { FactoryBot.create(:front_end_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    scenario 'display minutes by course' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 9), course: front_end_course)

      visit course_minutes_path(rails_course)
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月02日'
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年10月09日'

      visit course_minutes_path(front_end_course)
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年10月02日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月09日'
    end

    scenario 'display minutes by year' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 1), course: rails_course)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)

      visit course_minutes_path(rails_course)
      expect(page).to have_link '2024年'
      expect(page).to have_link '2025年'

      click_link '2024年'
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2025年01月01日'

      click_link '2025年'
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2025年01月01日'
    end

    scenario 'display latest year minutes when year is not specified' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 1), course: rails_course)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)

      visit course_minutes_path(rails_course)
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2025年01月01日'
    end

    scenario 'display github wiki link when the minute is exported' do
      exported_minute = FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 1), exported: true, course: rails_course)
      not_exported_minute = FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 1, 15), course: rails_course)

      visit course_minutes_path(rails_course)
      expect(page).to have_link 'GitHub Wikiで確認', href: github_wiki_url(exported_minute)
      expect(page).not_to have_link 'GitHub Wikiで確認', href: github_wiki_url(not_exported_minute)
    end

    scenario 'can access minutes list for each course by tab' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 2), course: rails_course)
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 10, 9), course: front_end_course)

      visit course_minutes_path(rails_course)
      expect(page).to have_link 'Railsエンジニアコース'
      expect(page).to have_link 'フロントエンドエンジニアコース'

      click_link 'Railsエンジニアコース'
      expect(current_path).to eq course_minutes_path(rails_course)

      click_link 'フロントエンドエンジニアコース'
      expect(current_path).to eq course_minutes_path(front_end_course)
    end
  end

  context 'when show the minute' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }

    before do
      login_as member
    end

    scenario 'show markdown and preview of the minute', :js do
      visit minute_path(minute)
      expect(page).to have_button 'Markdown'
      expect(page).to have_button 'Preview'

      click_button 'Markdown'
      expect(page).to have_selector 'pre#raw_markdown'
      expect(page).not_to have_selector 'div#markdown_preview'
      within('#raw_markdown') do
        expect(page).to have_content '# ふりかえり'
        expect(page).not_to have_selector 'h1', text: 'ふりかえり'
      end

      click_button 'Preview'
      expect(page).not_to have_selector 'pre#raw_markdown'
      expect(page).to have_selector 'div#markdown_preview'
      within('#markdown_preview') do
        expect(page).not_to have_content '# ふりかえり'
        expect(page).to have_selector 'h1', text: 'ふりかえり'
      end
    end
  end
end
