require 'rails_helper'

RSpec.describe "Attendances", type: :system do
  scenario 'not logged in user cannot access create attendance page' do
    minute = FactoryBot.create(:minute)
    visit new_minute_attendance_path(minute)

    expect(current_path).to eq root_path
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  context 'logged in user' do
    before do
      rails_course = FactoryBot.create(:rails_course)
      @minute = FactoryBot.create(:minute, course: rails_course)
      @member = FactoryBot.create(:member, course: rails_course)
    end

    scenario 'user can create day attendance', js: true do
      login_as @member
      travel_to @minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(@minute)
        choose '出席'
        choose '昼の部'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(@minute)
        expect(page).to have_content 'Attendance was successfully created.'
        expect(page).to have_link '出席編集' # Reactコンポーネントの表示を待つため、先に出席編集ボタンの表示を確認する
        within('#day_attendees') do
          have_selector 'li', text: @member.name
        end
      end
    end

    scenario 'user can create night attendance', js: true do
      login_as @member
      travel_to @minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(@minute)
        choose '出席'
        choose '夜の部'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(@minute)
        expect(page).to have_content 'Attendance was successfully created.'
        expect(page).to have_link '出席編集'
        within('#night_attendees') do
          have_selector 'li', text: @member.name
        end
      end
    end

    scenario 'user can create absence', js: true do
      login_as @member
      travel_to @minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(@minute)
        choose '欠席'
        fill_in '欠席理由', with: '仕事の都合のため。'
        fill_in '進捗報告', with: '今週は依頼されたIssueを進めていました。来週にはPRを提出できそうです。'
        click_button '出席を登録'

        expect(current_path).to eq edit_minute_path(@minute)
        expect(page).to have_content 'Attendance was successfully created.'
        expect(page).to have_link '出席編集'
        within('#absentees') do
          have_selector 'li', text: @member.name
          have_selector 'li', text: '欠席理由: 仕事の都合のため。'
          have_selector 'li', text: '今週は依頼されたIssueを進めていました。来週にはPRを提出できそうです。'
        end
      end
    end

    scenario 'user cannot create attendance twice' do
      login_as @member
      travel_to @minute.meeting_date.days_ago(1) do
        visit new_minute_attendance_path(@minute)
        choose '出席'
        choose '昼の部'
        click_button '出席を登録'

        visit new_minute_attendance_path(@minute)
        expect(current_path).to eq edit_minute_path(@minute)
        expect(page).to have_content 'You already registered attendance!'
      end
    end
  end
end
