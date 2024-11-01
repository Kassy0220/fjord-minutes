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

  context 'when edit attendance' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    scenario 'member can edit attendance to absence', :js do
      attendance = minute.attendances.create(status: :present, time: :day, member_id: member.id)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        within('#day_attendees') do
          click_link '出席編集'
        end
        expect(current_path).to eq edit_attendance_path(attendance)
        choose '昼の部'
        choose '昼の部' # チェックがついている'昼の部'を2度クリックして、チェックを外す
        choose '欠席'
        fill_in '欠席理由', with: '体調不良のため。'
        fill_in '進捗報告', with: 'PRのチームメンバーのレビューが通り、komagataさんにレビュー依頼をお願いしているところです。'
        click_button '出席を更新'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を更新しました'
        within('#day_attendees') do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#absentees') do
          expect(page).to have_selector 'li', text: member.name
          expect(page).to have_selector 'li', text: '欠席理由: 体調不良のため。'
          expect(page).to have_selector 'li', text: 'PRのチームメンバーのレビューが通り、komagataさんにレビュー依頼をお願いしているところです。'
        end
      end
    end

    scenario 'member can edit absence to attendance', :js do
      attendance = minute.attendances.create(status: :absent, absence_reason: '仕事の都合のため。', progress_report: '今週の進捗はありません。', member_id: member.id)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        within('#absentees') do
          click_link '出席編集'
        end
        expect(current_path).to eq edit_attendance_path(attendance)
        choose '欠席'
        fill_in '欠席理由', with: ''
        fill_in '進捗報告', with: ''
        choose '出席'
        choose '夜の部'
        click_button '出席を更新'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を更新しました'
        within('#absentees', visible: false) do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#night_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member treated as unexcused absentee can create attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        within('#unexcused_absentees') do
          expect(page).to have_selector 'li', text: member.name
          expect(page).to have_selector 'a', text: '出席登録'
          click_link '出席登録'
        end
        expect(current_path).to eq new_minute_attendance_path(minute)
        choose '出席'
        choose '昼の部'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席を登録しました'
        within('#unexcused_absentees', visible: false) do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#day_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member cannot update attendance with invalid input' do
      minute.attendances.create(status: :present, time: :day, member_id: member.id)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        within('#day_attendees') do
          click_link '出席編集'
        end
        choose '欠席'
        fill_in '欠席理由', with: '体調不良のため。'
        fill_in '進捗報告', with: '今週の進捗はありません。'
        choose '出席'
        choose '夜の部'
        click_button '出席を更新'
        expect(page).to have_content '欠席理由は入力しないでください'
        expect(page).to have_content '進捗報告は入力しないでください'

        choose '欠席'
        fill_in '欠席理由', with: ''
        fill_in '進捗報告', with: ''
        click_button '出席を更新'
        expect(page).to have_content '出席時間帯は入力しないでください'
        expect(page).to have_content '欠席理由を入力してください'
        expect(page).to have_content '進捗報告を入力してください'
      end
    end
  end
end
