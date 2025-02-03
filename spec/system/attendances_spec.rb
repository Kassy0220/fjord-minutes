# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attendances', type: :system do
  scenario 'not logged in user cannot access create attendance page' do
    minute = FactoryBot.create(:minute)
    visit new_minute_attendance_path(minute)

    expect(current_path).to eq root_path
    expect(page).to have_content 'ログインもしくはアカウント登録してください。'
  end

  scenario 'attendance registration button is not displayed when logged in as admin' do
    minute = FactoryBot.create(:minute)
    login_as_admin FactoryBot.create(:admin)

    visit edit_minute_path(minute)
    expect(page).not_to have_link '出席予定を登録する'
  end

  context 'when logged in user' do
    let(:rails_course) { FactoryBot.create(:rails_course) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }
    let(:member) { FactoryBot.create(:member, course: rails_course) }

    before do
      login_as member
    end

    scenario 'member can create afternoon attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        expect(page).to have_link '出席予定を登録する'
        click_link '出席予定を登録する'

        expect(current_path).to eq new_minute_attendance_path(minute)
        choose '昼の部に出席'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を登録しました'
        expect(page).not_to have_link '出席予定を登録する'
        expect(page).to have_link '出席予定を変更する'
        within('#afternoon_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member can create night attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        expect(page).to have_link '出席予定を登録する'
        click_link '出席予定を登録する'

        choose '夜の部に出席'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を登録しました'
        expect(page).not_to have_link '出席予定を登録する'
        expect(page).to have_link '出席予定を変更する'
        within('#night_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member can create absence', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        expect(page).to have_link '出席予定を登録する'
        click_link '出席予定を登録する'

        choose '欠席'
        fill_in '欠席理由', with: '仕事の都合のため。'
        fill_in '進捗報告', with: '#1000 チームメンバーのレビュー待ちの状態です。'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を登録しました'
        expect(page).not_to have_link '出席予定を登録する'
        expect(page).to have_link '出席予定を変更する'
        within('#absentees') do
          expect(page).to have_selector 'li', text: member.name
          expect(page).to have_selector 'li', text: '仕事の都合のため。'
          expect(page).to have_selector 'li', text: '#1000 チームメンバーのレビュー待ちの状態です。'
          expect(page).to have_link '#1000', href: 'https://github.com/fjordllc/bootcamp/issues/1000'
        end
      end
    end

    scenario 'treated as unexcused absentees if member create neither attendance nor absence', :js do
      visit edit_minute_path(minute)
      within('#unexcused_absentees') do
        expect(page).to have_selector 'li', text: 'alice'
      end
    end

    scenario 'hibernated member is not displayed as present, absent or unexcused absent', :js do
      hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
      hibernated_member.hibernations.create!
      expect(hibernated_member.hibernated?).to be true

      visit edit_minute_path(minute)
      within('#afternoon_attendees', visible: false) do
        expect(page).not_to have_selector 'li', text: hibernated_member.name
      end
      within('#night_attendees', visible: false) do
        expect(page).not_to have_selector 'li', text: hibernated_member.name
      end
      within('#absentees', visible: false) do
        expect(page).not_to have_selector 'li', text: hibernated_member.name
      end
      within('#unexcused_absentees', visible: false) do
        expect(page).not_to have_selector 'li', text: hibernated_member.name
      end

      hibernated_member.hibernations.last.update!(finished_at: Time.zone.today)
      expect(hibernated_member.hibernated?).to be false
      visit edit_minute_path(minute)
      within('#unexcused_absentees') do
        expect(page).to have_selector 'li', text: hibernated_member.name
      end
    end

    scenario 'member cannot create attendance twice' do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)
        choose '昼の部に出席'
        click_button '出席を登録'

        visit new_minute_attendance_path(minute)
        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content 'すでに出席予定を登録済みです'
      end
    end

    scenario 'attendance registration button is not displayed if meeting is already finished' do
      travel_to minute.meeting_date + 1.day do
        visit edit_minute_path(minute)
        expect(page).not_to have_link '出席予定を登録する'
      end
    end

    scenario 'member cannot create attendance to already finished meeting' do
      travel_to minute.meeting_date.days_since(1) do
        visit new_minute_attendance_path(minute)
        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '終了したミーティングには出席予定を登録できません'
      end
    end

    scenario 'member cannot create attendance with invalid input', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(minute)

        # 出欠を選択していない場合、送信ボタンはdisabledとなる
        expect(page).to have_button '出席を登録', disabled: true

        choose '欠席'
        click_button '出席を登録'
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

    scenario 'member can change from present to absent', :js do
      attendance = FactoryBot.create(:attendance, member:, minute:)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        click_link '出席予定を変更する'
        expect(current_path).to eq edit_attendance_path(attendance)

        expect(page).to have_checked_field '昼の部に出席'
        choose '欠席'
        fill_in '欠席理由', with: '体調不良のため。'
        fill_in '進捗報告', with: '#1000 チームメンバーのレビュー待ちの状態です。'
        click_button '出席を更新'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を更新しました'
        within('#afternoon_attendees', visible: false) do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#absentees') do
          expect(page).to have_selector 'li', text: member.name
          expect(page).to have_selector 'li', text: '体調不良のため。'
          expect(page).to have_selector 'li', text: '#1000 チームメンバーのレビュー待ちの状態です。'
        end
      end
    end

    scenario 'member can change from absent to present', :js do
      attendance = FactoryBot.create(:attendance, :absence, member:, minute:)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        click_link '出席予定を変更する'
        expect(current_path).to eq edit_attendance_path(attendance)

        expect(page).to have_checked_field '欠席'
        choose '夜の部に出席'
        click_button '出席を更新'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を更新しました'
        within('#absentees', visible: false) do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#night_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'unexcused absentee can create attendance', :js do
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        within('#unexcused_absentees') do
          expect(page).to have_selector 'li', text: member.name
        end
        expect(page).to have_link '出席予定を登録する'
        click_link '出席予定を登録する'
        expect(current_path).to eq new_minute_attendance_path(minute)

        choose '昼の部に出席'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '出席予定を登録しました'
        within('#unexcused_absentees', visible: false) do
          expect(page).not_to have_selector 'li', text: member.name
        end
        within('#afternoon_attendees') do
          expect(page).to have_selector 'li', text: member.name
        end
      end
    end

    scenario 'member cannot update attendance with invalid input' do
      FactoryBot.create(:attendance, member:, minute:)
      travel_to minute.meeting_date.days_ago(1) do
        visit edit_minute_path(minute)
        click_link '出席予定を変更する'

        choose '欠席'
        click_button '出席を更新'
        expect(page).to have_content '欠席理由を入力してください'
        expect(page).to have_content '進捗報告を入力してください'
      end
    end

    scenario 'edit attendance button is not displayed if meeting is already finished' do
      travel_to minute.meeting_date + 1.day do
        visit edit_minute_path(minute)
        expect(page).not_to have_link '出席予定を変更する'
      end
    end

    scenario 'member cannot edit attendance for the finished meeting' do
      attendance = FactoryBot.create(:attendance, member:, minute:)
      travel_to minute.meeting_date + 1.day do
        visit edit_attendance_path(attendance)
        expect(current_path).to eq edit_minute_path(minute)
        expect(page).to have_content '終了したミーティングの出席予定は変更できません'
      end
    end
  end

  context 'when admin' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:admin) { FactoryBot.create(:admin) }
    let(:minute) { FactoryBot.create(:minute, course: rails_course) }

    before do
      login_as_admin admin
    end

    scenario 'admin cannot access create attendance page' do
      visit new_minute_attendance_path(minute)
      expect(current_path).to eq edit_minute_path(minute)
    end
  end
end
