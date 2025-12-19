# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes', type: :system do
  include MinutesHelper

  describe 'edit minute' do
    context 'when logged in as admin' do
      let!(:rails_course) { FactoryBot.create(:rails_course) }
      let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
      let(:minute) { FactoryBot.create(:minute, meeting:) }

      before do
        login_as_admin FactoryBot.create(:admin)
        visit edit_minute_path(minute)
      end

      scenario 'can edit all minute content', :js do
        within('#release_branch') do
          expect(page).to have_selector 'button', text: '編集'
        end
        within('#release_note') do
          expect(page).to have_selector 'button', text: '編集'
        end
        within('#topic_form') do
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
        within('#release_branch') do
          expect(page).to have_link 'https://example.com/fjordllc/bootcamp/pull/1000', href: 'https://example.com/fjordllc/bootcamp/pull/1000'
          expect(page).not_to have_selector 'input[type="text"]'

          click_button '編集'
          expect(page).to have_selector 'input[type="text"]'
          fill_in 'release_branch_field', with: 'https://example.com/fjordllc/bootcamp/pull/9999'
          click_button '更新'

          expect(page).to have_link 'https://example.com/fjordllc/bootcamp/pull/9999', href: 'https://example.com/fjordllc/bootcamp/pull/9999'
          expect(page).not_to have_selector 'input[type="text"]'
        end

        within('#release_note') do
          expect(page).to have_link 'https://example.com/announcements/100', text: 'https://example.com/announcements/100'
          expect(page).not_to have_selector 'input[type="text"]'

          click_button '編集'
          expect(page).to have_selector 'input[type="text"]'
          fill_in 'release_note_field', with: 'https://example.com/fjordllc/bootcamp/pull/999'
          click_button '更新'

          expect(page).to have_link 'https://example.com/fjordllc/bootcamp/pull/999', text: 'https://example.com/fjordllc/bootcamp/pull/999'
          expect(page).not_to have_selector 'input[type="text"]'
        end
      end

      scenario 'can create, edit and delete topic', :js do
        within('#topics') do
          expect(page).to have_content '話題にしたいこと・心配事はありません。'
        end
        within('#topic_form') do
          expect(page).to have_selector 'input[type="text"]'
          expect(find('button', text: '作成')).to be_disabled
          fill_in 'new_topic_field', with: '今週ミートアップがありますのでぜひご参加を！'
          click_button '作成'
        end
        within('#topics') do
          expect(page).not_to have_content '話題にしたいこと・心配事はありません。'
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

      scenario 'cannot edit and destroy topics created by others', :js do
        minute.topics.create(content: 'テストが通らないのでどなたかペアプロをお願いします！', topicable: FactoryBot.create(:member, course: rails_course))

        visit edit_minute_path(minute)
        within('#topics') do
          expect(page).to have_selector 'li', text: 'テストが通らないのでどなたかペアプロをお願いします！(alice)'
          expect(page).not_to have_selector 'button', text: '編集'
          expect(page).not_to have_selector 'button', text: '削除'
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
        meeting = rails_course.meetings.create!(date: Date.new(2024, 10, 9))
        minute = FactoryBot.create(:minute, meeting:)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2024年10月23日 (水)'

          click_button '編集'
          expect(page).to have_button '2024年10月23日'
          expect(page).to have_button '2024年11月06日'
          expect(page).to have_button '2024年11月20日'
          expect(page).to have_button '2024年12月04日'
          click_button '2024年11月06日'
          click_button '更新'
          expect(page).not_to have_button '更新'
          expect(page).to have_content '2024年11月06日 (水)'
          expect(meeting.reload.next_date).to eq Date.new(2024, 11, 6)
        end
      end

      scenario 'message is displayed if next meeting is holiday' do
        meeting = rails_course.meetings.create!(date: Date.new(2026, 1, 14))
        minute = FactoryBot.create(:minute, meeting:)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2026年01月28日 (水)'
          click_button '編集'
          # ボタンのテキストで絞り込みが難しいため、data属性で特定する
          button_displaying_holiday = find('button[data-meeting-date="2026-02-11"]')
          expect(button_displaying_holiday.text).to include '建国記念の日'
          button_displaying_holiday.click
          click_button '更新'
          expect(page).to have_content '2026年02月11日 (水)'
          expect(page).to have_content '次回開催日は建国記念の日です。もしミーティングをお休みにする場合は、開催日を変更しましょう。'
        end
      end

      # 2025年は52週まで
      scenario 'possible meeting dates across the year boundary are displayed correctly when year has 52 weeks' do
        odd_week_meeting = rails_course.meetings.create!(date: Date.new(2025, 12, 3))
        minute = FactoryBot.create(:minute, meeting: odd_week_meeting)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2025年12月17日 (水)'
          click_button '編集'
          expect(page).to have_button '2025年12月17日'
          expect(page).to have_button '2025年12月31日'
          expect(page).to have_button '2026年01月14日'
          expect(page).to have_button '2026年01月28日'
        end

        even_week_meeting = FactoryBot.create(:front_end_course).meetings.create!(date: Date.new(2025, 12, 10))
        minute = FactoryBot.create(:minute, meeting: even_week_meeting)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2025年12月24日 (水)'
          click_button '編集'
          expect(page).to have_button '2025年12月24日'
          expect(page).to have_button '2026年01月07日'
          expect(page).to have_button '2026年01月21日'
          expect(page).to have_button '2026年02月04日'
        end
      end

      # 2026年は53週まで
      scenario 'possible meeting dates across the year boundary are displayed correctly when year has 53 weeks' do
        odd_week_meeting = rails_course.meetings.create!(date: Date.new(2026, 12, 16))
        minute = FactoryBot.create(:minute, meeting: odd_week_meeting)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2026年12月30日 (水)'
          click_button '編集'
          expect(page).to have_button '2026年12月30日'
          expect(page).to have_button '2027年01月06日'
          expect(page).to have_button '2027年01月20日'
          expect(page).to have_button '2027年02月03日'
        end

        even_week_meeting = FactoryBot.create(:front_end_course).meetings.create!(date: Date.new(2026, 12, 9))
        minute = FactoryBot.create(:minute, meeting: even_week_meeting)
        visit edit_minute_path(minute)
        within('#next_meeting_date_form') do
          expect(page).to have_content '2026年12月23日 (水)'
          click_button '編集'
          expect(page).to have_button '2026年12月23日'
          expect(page).to have_button '2027年01月13日'
          expect(page).to have_button '2027年01月27日'
          expect(page).to have_button '2027年02月10日'
        end
      end

      scenario 'kanban link is displayed for each course' do
        expect(page).to have_link 'bootcampカンバン', href: 'https://github.com/orgs/fjordllc/projects/7'

        front_end_course = FactoryBot.create(:front_end_course)
        front_end_course_minute = FactoryBot.create(:minute, course: front_end_course)
        visit edit_minute_path(front_end_course_minute)
        expect(page).to have_link 'agentカンバン', href: 'https://github.com/orgs/fjordllc/projects/4'
      end
    end

    context 'when logged in as member' do
      let!(:rails_course) { FactoryBot.create(:rails_course) }
      let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
      let(:minute) { FactoryBot.create(:minute, meeting:) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }

      before do
        login_as member
      end

      scenario 'can edit only topics', :js do
        visit edit_minute_path(minute)
        within('#release_branch') do
          expect(page).not_to have_selector 'button', text: '編集'
        end
        within('#release_note') do
          expect(page).not_to have_selector 'button', text: '編集'
        end
        within('#topic_form') do
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

      scenario 'can create, edit and delete topic', :js do
        visit edit_minute_path(minute)

        within('#topics') do
          expect(page).to have_content '話題にしたいこと・心配事はありません。'
        end
        within('#topic_form') do
          expect(page).to have_selector 'input[type="text"]'
          expect(find('button', text: '作成')).to be_disabled
          fill_in 'new_topic_field', with: 'CI上でテストが落ちています、皆さんはいかがでしょうか？'
          click_button '作成'
        end
        within('#topics') do
          expect(page).not_to have_content '話題にしたいこと・心配事はありません。'
          expect(page).to have_selector 'li', text: 'CI上でテストが落ちています、皆さんはいかがでしょうか？(alice)'
          expect(page).to have_selector 'button', text: '編集'
          expect(page).to have_selector 'button', text: '削除'

          click_button '編集'
          fill_in 'edit_topic_field', with: 'ローカル環境でもテストが落ちています'
          click_button '更新'
          expect(page).to have_selector 'li', text: 'ローカル環境でもテストが落ちています(alice)'

          click_button '削除'
          expect(page).not_to have_selector 'li', text: 'ローカル環境でもテストが落ちています(alice)'
        end
      end

      scenario 'cannot edit and destroy topics created by others', :js do
        minute.topics.create(content: 'テストが通らないのでどなたかペアプロをお願いします！', topicable: FactoryBot.create(:member, :another_member, course: rails_course))

        visit edit_minute_path(minute)
        within('#topics') do
          expect(page).to have_selector 'li', text: 'テストが通らないのでどなたかペアプロをお願いします！(bob)'
          expect(page).not_to have_selector 'button', text: '編集'
          expect(page).not_to have_selector 'button', text: '削除'
        end
      end

      scenario 'cannot access to other course minutes' do
        logout
        other_course = FactoryBot.create(:front_end_course)
        other_course_member = FactoryBot.create(:member, :another_member, course: other_course)
        login_as other_course_member

        visit edit_minute_path(minute)
        expect(current_path).to eq root_path
        expect(page).to have_content '自分が所属していないコースの議事録を編集することはできません'
      end

      scenario 'kanban link is displayed' do
        visit edit_minute_path(minute)
        expect(page).to have_link 'bootcampカンバン', href: 'https://github.com/orgs/fjordllc/projects/7'
      end
    end
  end

  describe 'show minutes' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:front_end_course) { FactoryBot.create(:front_end_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    scenario 'display messages if minute is none' do
      visit course_minutes_path(rails_course)
      expect(page).to have_content 'Railsエンジニアコースの議事録はまだ作成されていません。'
    end

    scenario 'display minutes by course' do
      rails_course_minute = FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 10, 2), course: rails_course))
      front_end_course_minute = FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 10, 9), course: front_end_course))

      visit course_minutes_path(rails_course)
      within('#course_tab') do
        expect(page).to have_link 'Railsエンジニアコース'
        expect(page).to have_link 'フロントエンドエンジニアコース'
      end

      within('#course_tab') do
        click_link 'Railsエンジニアコース'
      end
      expect(current_path).to eq course_minutes_path(rails_course)
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月02日', href: minute_path(rails_course_minute)
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年10月09日', href: minute_path(front_end_course_minute)

      within('#course_tab') do
        click_link 'フロントエンドエンジニアコース'
      end
      expect(current_path).to eq course_minutes_path(front_end_course)
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年10月02日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年10月09日'
    end

    scenario 'display minutes by year' do
      FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 1, 1), course: rails_course))
      FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course: rails_course))

      visit course_minutes_path(rails_course)
      within('#years_tab') do
        expect(page).to have_link '2024年'
        expect(page).to have_link '2025年'
      end

      within('#years_tab') do
        click_link '2024年'
      end
      expect(page).to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2025年01月01日'

      within('#years_tab') do
        click_link '2025年'
      end
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2025年01月01日'
    end

    scenario 'display latest year minutes when year is not specified' do
      FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 1, 1), course: rails_course))
      FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course: rails_course))

      visit course_minutes_path(rails_course)
      expect(page).not_to have_link 'ふりかえり・計画ミーティング2024年01月01日'
      expect(page).to have_link 'ふりかえり・計画ミーティング2025年01月01日'
    end

    scenario 'display github wiki link when the minute is exported' do
      # CI上でリポジトリのwikiのURLを参照した際にエラーが発生しないように、適当な値を返すようにする
      allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL').and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')
      allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL').and_return('https://example.com/fjordllc/agent-wiki.wiki.git')

      exported_minute = FactoryBot.create(:minute, exported: true, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 1, 1), course: rails_course))
      not_exported_minute = FactoryBot.create(:minute, meeting: FactoryBot.create(:meeting, date: Time.zone.local(2024, 1, 15), course: rails_course))

      visit course_minutes_path(rails_course)
      expect(page).to have_link 'GitHub Wikiで確認', href: github_wiki_url(exported_minute)
      expect(page).not_to have_link 'GitHub Wikiで確認', href: github_wiki_url(not_exported_minute)
    end
  end

  describe 'show minute' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }
    let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
    let(:minute) { FactoryBot.create(:minute, meeting:) }

    scenario 'show markdown and preview of the minute', :js do
      login_as member
      visit minute_path(minute)
      within('#preview_tab') do
        expect(page).to have_button 'Markdown'
        expect(page).to have_button 'Preview'
      end

      within('#preview_tab') do
        click_button 'Markdown'
      end
      expect(page).to have_selector 'pre#raw_markdown'
      expect(page).not_to have_selector 'div#markdown_preview'
      within('#raw_markdown') do
        expect(page).to have_content '# ふりかえり'
        expect(page).not_to have_selector 'h1', text: 'ふりかえり'
      end

      within('#preview_tab') do
        click_button 'Preview'
      end
      expect(page).not_to have_selector 'pre#raw_markdown'
      expect(page).to have_selector 'div#markdown_preview'
      within('#markdown_preview') do
        expect(page).not_to have_content '# ふりかえり'
        expect(page).to have_selector 'h1', text: 'ふりかえり'
      end
    end

    describe 'export minute' do
      let(:admin) { FactoryBot.create(:admin) }

      scenario 'export button is displayed when logged in as admin' do
        login_as_admin admin
        visit minute_path(minute)
        expect(page).to have_button 'GitHub Wiki にエクスポート'
      end

      scenario 'admin can export minute to GitHub Wiki' do
        login_as_admin admin
        visit minute_path(minute)
        expect(page).not_to have_link 'GitHub Wikiで確認'

        # CI上でリポジトリのwikiのURLを参照した際にエラーが発生しないように、適当な値を返すようにする
        allow(ENV).to receive(:fetch).with('BOOTCAMP_WIKI_URL').and_return('https://example.com/fjordllc/bootcamp-wiki.wiki.git')
        allow(ENV).to receive(:fetch).with('AGENT_WIKI_URL').and_return('https://example.com/fjordllc/agent-wiki.wiki.git')
        # GitHub Wikiリポジトリにpushされないように、コントローラー内で取得されるMinuteオブジェクトをスタブする
        allow(Minute).to receive(:find).with(minute.id.to_s).and_return(minute)
        allow(minute).to receive(:export_to_github_wiki).and_return(nil)

        click_button 'GitHub Wiki にエクスポート'
        expect(current_path).to eq course_minutes_path(minute.course)
        expect(page).to have_content 'GitHub Wikiに議事録を反映させました'
        visit minute_path(minute)
        expect(page).to have_link 'GitHub Wikiで確認'
      end

      scenario 'member cannot export minute to GitHub Wiki' do
        login_as member
        visit minute_path(minute)
        expect(page).not_to have_button 'GitHub Wiki にエクスポート'
      end
    end
  end
end
