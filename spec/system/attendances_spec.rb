# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attendances', type: :system do
  scenario 'not logged in user cannot access create attendance page' do
    minute = FactoryBot.create(:minute)
    visit new_minute_attendance_path(minute)

    expect(current_path).to eq root_path
    expect(page).to have_content 'ログインもしくはアカウント登録してください。'
  end

  context 'when logged in user' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    scenario 'member can create day attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)
        choose '出席'
        choose '昼の部'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を登録しました'
        expect(page).to have_link '出席編集' # Reactコンポーネントの表示を待つため、先に出席編集ボタンの表示を確認する
        within('#day_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member can create night attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)
        choose '出席'
        choose '夜の部'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を登録しました'
        expect(page).to have_link '出席編集'
        within('#night_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member can create absence', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)
        choose '欠席'
        fill_in '欠席理由', with: '仕事の都合のため。'
        fill_in '進捗報告', with: '今週は依頼されたIssueを進めていました。来週にはPRを提出できそうです。'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を登録しました'
        expect(page).to have_link '出席編集'
        within('#absentees') do
          expect(page).to have_selector 'li', text: member.name
          expect(page).to have_selector 'li', text: '欠席理由: 仕事の都合のため。'
          expect(page).to have_selector 'li', text: '今週は依頼されたIssueを進めていました。来週にはPRを提出できそうです。'
        end
      end
    end

    scenario 'treated as unexcused absentees if member create neither attendance nor absence', :js do
      visit edit_minute_path(minute)
      within('#unexcused_absentees') do
        expect(page).to have_selector 'li', text: 'alice'
      end
    end

    scenario 'member cannot create attendance twice' do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)
        choose '出席'
        choose '昼の部'
        click_button '出席を登録'

        visit new_minute_attendance_path(minute)
        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content 'すでに出席を登録済みです'
      end
    end

    scenario 'member cannot create attendance to already finished meeting' do
      travel_to minute.meeting_date.days_since(1) do
        visit new_minute_attendance_path(minute)
        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '終了したミーティングには出席できません'
      end
    end

    scenario 'member cannot create attendance with invalid input', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)

        click_button '出席を登録'
        expect(page).to have_content '出席状況を入力してください'

        choose '欠席'
        fill_in '欠席理由', with: '仕事の都合。'
        fill_in '進捗報告', with: '今週の進捗は特にありません。'
        choose '出席'
        click_button '出席を登録'
        expect(page).to have_content '出席時間帯を入力してください'
        expect(page).to have_content '欠席理由は入力しないでください'
        expect(page).to have_content '進捗報告は入力しないでください'

        choose '出席'
        choose '昼の部'
        choose '欠席'
        fill_in '欠席理由', with: ''
        fill_in '進捗報告', with: ''
        click_button '出席を登録'
        expect(page).to have_content '出席時間帯は入力しないでください'
        expect(page).to have_content '欠席理由を入力してください'
        expect(page).to have_content '進捗報告を入力してください'
      end
    end
  end
end
