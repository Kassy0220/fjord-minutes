# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attendances', type: :system do
  scenario 'not logged in user cannot access create attendance page' do
    visit new_meeting_attendance_path(FactoryBot.create(:meeting))

    expect(current_path).to eq root_path
    expect(page).to have_content 'ログインもしくはアカウント登録してください。'
  end

  context 'when logged in as member' do
    describe 'create attendance' do
      let(:rails_course) { FactoryBot.create(:rails_course) }
      let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
      let(:minute) { FactoryBot.create(:minute, meeting:) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }

      before do
        login_as member
      end

      scenario 'for afternoon session', :js do
        travel_to meeting.date do
          visit edit_minute_path(minute)
          expect(page).to have_link '出席予定を登録する'
          click_link '出席予定を登録する'

          expect(current_path).to eq new_meeting_attendance_path(meeting)
          find('#label_afternoon').click
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

      scenario 'for night session', :js do
        travel_to meeting.date do
          visit edit_minute_path(minute)
          expect(page).to have_link '出席予定を登録する'
          click_link '出席予定を登録する'

          find('#label_night').click
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

      scenario 'as absence', :js do
        travel_to meeting.date do
          visit edit_minute_path(minute)
          expect(page).to have_link '出席予定を登録する'
          click_link '出席予定を登録する'

          find('#label_absent').click
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

      scenario 'it is treated as unexcused absence if member does not create attendance', :js do
        visit edit_minute_path(minute)
        within('#unexcused_absentees') do
          expect(page).to have_selector 'li', text: 'alice'
        end
      end

      scenario 'hibernated member is not displayed on the edit minute page', :js do
        hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
        hibernated_member.hibernations.create!
        expect(hibernated_member.hibernated?).to be true

        travel_to meeting.date do
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
      end

      scenario 'member cannot create attendance with invalid input', :js do
        travel_to meeting.date do
          visit edit_minute_path(minute)
          click_link '出席予定を登録する'

          # 出欠を選択していない場合、送信ボタンはdisabledとなる
          expect(page).to have_button '出席を登録', disabled: true

          find('#label_absent').click
          click_button '出席を登録'
          expect(page).to have_content '欠席理由を入力してください'
          expect(page).to have_content '進捗報告を入力してください'
        end
      end

      scenario 'member cannot create attendance to the same meeting twice' do
        travel_to meeting.date do
          visit edit_minute_path(minute)
          click_link '出席予定を登録する'

          find('#label_afternoon').click
          click_button '出席を登録'

          visit new_meeting_attendance_path(meeting)
          expect(current_path).to eq edit_minute_path(minute)
          expect(page).to have_content 'すでに出席予定を登録済みです'
        end
      end

      scenario 'member cannot create attendance if meeting is finished' do
        travel_to meeting.date.tomorrow do
          visit edit_minute_path(minute)
          expect(page).not_to have_link '出席予定を登録する'

          visit new_meeting_attendance_path(meeting)
          expect(current_path).to eq edit_minute_path(minute)
          expect(page).to have_content '終了したミーティングには出席予定を登録できません'
        end
      end

      scenario 'member cannot create attendance to other course meeting' do
        logout
        other_course = FactoryBot.create(:front_end_course)
        other_course_member = FactoryBot.create(:member, :another_member, course: other_course)
        login_as other_course_member

        travel_to meeting.date do
          visit new_meeting_attendance_path(meeting)
          expect(current_path).to eq root_path
          expect(page).to have_content '自分が所属していないコースのミーティングには出席登録できません'
        end
      end
    end

    describe 'edit attendance' do
      let(:rails_course) { FactoryBot.create(:rails_course) }
      let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
      let(:minute) { FactoryBot.create(:minute, meeting:) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }

      before do
        login_as member
      end

      scenario 'from attended to absent', :js do
        attendance = FactoryBot.create(:attendance, member:, meeting:)
        travel_to meeting.date do
          visit edit_minute_path(minute)
          click_link '出席予定を変更する'

          expect(current_path).to eq edit_attendance_path(attendance)
          # デザインの都合上ラジオボタンは display: none; となっているため、visible: false をつける
          expect(page).to have_checked_field('昼の部に出席', visible: false)
          find('#label_absent').click
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

      scenario 'from absent to attended', :js do
        attendance = FactoryBot.create(:attendance, :absence, member:, meeting:)
        travel_to meeting.date do
          visit edit_minute_path(minute)
          click_link '出席予定を変更する'

          expect(current_path).to eq edit_attendance_path(attendance)
          # デザインの都合上ラジオボタンは display: none; となっているため、visible: false をつける
          expect(page).to have_checked_field('欠席', visible: false)
          find('#label_night').click
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

      scenario 'member cannot update attendance with invalid input' do
        FactoryBot.create(:attendance, member:, meeting:)
        travel_to meeting.date do
          visit edit_minute_path(minute)
          click_link '出席予定を変更する'

          find('#label_absent').click
          click_button '出席を更新'
          expect(page).to have_content '欠席理由を入力してください'
          expect(page).to have_content '進捗報告を入力してください'
        end
      end

      scenario 'member cannot edit attendance if meeting is finished' do
        attendance = FactoryBot.create(:attendance, member:, meeting:)
        travel_to meeting.date.tomorrow do
          visit edit_minute_path(minute)
          expect(page).not_to have_link '出席予定を変更する'

          visit edit_attendance_path(attendance)
          expect(current_path).to eq edit_minute_path(minute)
          expect(page).to have_content '終了したミーティングの出席予定は変更できません'
        end
      end
    end
  end

  context 'when logged in as admin' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
    let(:minute) { FactoryBot.create(:minute, meeting:) }

    before do
      login_as_admin FactoryBot.create(:admin)
    end

    scenario 'admin cannot visit create attendance page' do
      visit edit_minute_path(minute)
      expect(page).not_to have_link '出席予定を登録する'

      visit new_meeting_attendance_path(meeting)
      expect(current_path).to eq edit_minute_path(minute)
    end
  end
end
