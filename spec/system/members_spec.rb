# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Members', type: :system do
  describe 'show member' do
    scenario 'user can see member page of all course' do
      rails_course = FactoryBot.create(:rails_course)
      front_end_course = FactoryBot.create(:front_end_course)
      member = FactoryBot.create(:member, course: rails_course)
      another_member = FactoryBot.create(:member, :another_member, course: front_end_course)

      login_as member
      visit member_path(member)
      expect(page).to have_selector 'h1', text: 'aliceさん'
      expect(page).to have_button 'チーム開発を抜ける'

      visit member_path(another_member)
      expect(page).to have_selector 'h1', text: 'bobさん'
      expect(page).not_to have_button 'チーム開発を抜ける'
    end

    describe 'display member\'s attendances' do
      let(:rails_course) { FactoryBot.create(:rails_course) }
      let(:member) { FactoryBot.create(:member, course: rails_course, created_at: Time.zone.local(2024, 12, 1)) }

      before do
        login_as member
      end

      scenario 'all attendances are displayed as table', :js do
        create_meetings(course: rails_course, first_meeting_date: Time.zone.local(2025, 1, 1), count: 4)
        FactoryBot.create(:attendance, member:, meeting: rails_course.meetings.first)
        FactoryBot.create(:attendance, :night, member:, meeting: rails_course.meetings.second)
        FactoryBot.create(:attendance, :absence, member:, meeting: rails_course.meetings.third)

        visit member_path(member)
        expect(page).to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'dd[data-attendance-on="2025-01-01"]', text: '昼'
        expect(page).to have_selector 'dt[data-attendance-on="2025-01-15"]', text: '01/15'
        expect(page).to have_selector 'dd[data-attendance-on="2025-01-15"]', text: '夜'
        expect(page).to have_selector 'dt[data-attendance-on="2025-02-05"]', text: '02/05'
        expect(page).to have_selector 'dd[data-attendance-on="2025-02-05"]', text: '欠席'
        expect(page).to have_selector 'dt[data-attendance-on="2025-02-19"]', text: '02/19'
        expect(page).to have_selector 'dd[data-attendance-on="2025-02-19"]', text: '---'

        attendance = Attendance.find_by(attended: false)
        expect(page).not_to have_selector "div#absence_reason_for_attendance_#{attendance.id}", text: '体調不良のため。'
        within('dd[data-attendance-on="2025-02-05"]') do
          find("span[data-tooltip-target='absence_reason_for_attendance_#{attendance.id}']").hover
          expect(page).to have_selector "div#absence_reason_for_attendance_#{attendance.id}", text: '体調不良のため。'
        end
      end

      scenario 'attendances are divided by year', :js do
        FactoryBot.create(:meeting, date: Time.zone.local(2024, 12, 18), course: rails_course)
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course: rails_course)
        rails_course.meetings.each { |meeting| FactoryBot.create(:attendance, member:, meeting:) }

        visit member_path(member)
        expect(page).to have_selector 'div[data-meeting-year="2024"]'
        expect(page).to have_selector 'div[data-meeting-year="2025"]'

        within('div[data-meeting-year="2024"]') do
          expect(page).to have_selector 'dt[data-attendance-on="2024-12-18"]', text: '12/18'
          expect(page).to have_selector 'dd[data-attendance-on="2024-12-18"]', text: '昼'
        end
        within('div[data-meeting-year="2025"]') do
          expect(page).to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
          expect(page).to have_selector 'dd[data-attendance-on="2025-01-01"]', text: '昼'
        end
      end

      scenario 'attendances are divided in half year', :js do
        create_meetings(course: rails_course, first_meeting_date: Time.zone.local(2025, 1, 1), count: 13)
        rails_course.meetings.each { |meeting| FactoryBot.create(:attendance, member:, meeting:) }

        visit member_path(member)
        expect(page).to have_selector 'div[data-attendance-table="1"]'
        expect(page).to have_selector 'div[data-attendance-table="2"]'

        within('div[data-attendance-table="1"]') do
          expect(page).to have_selector 'dt[data-attendance-on]', count: 12
          expect(page).to have_selector 'dd[data-attendance-on]', count: 12
          expect(page).to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
          expect(page).to have_selector 'dd[data-attendance-on="2025-01-01"]', text: '昼'
          expect(page).to have_selector 'dt[data-attendance-on="2025-06-18"]', text: '06/18'
          expect(page).to have_selector 'dd[data-attendance-on="2025-06-18"]', text: '昼'
        end
        within('div[data-attendance-table="2"]') do
          expect(page).to have_selector 'dt[data-attendance-on]', count: 1
          expect(page).to have_selector 'dd[data-attendance-on]', count: 1
          expect(page).to have_selector 'dt[data-attendance-on="2025-07-02"]', text: '07/02'
          expect(page).to have_selector 'dd[data-attendance-on="2025-07-02"]', text: '昼'
        end
      end

      scenario 'attendances are displayed until the hibernation started if the member is hibernated', :js do
        hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course, created_at: Time.zone.local(2025, 1, 1))
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 15), course: rails_course)
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 2, 5), course: rails_course)
        FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 2, 1))

        visit member_path(hibernated_member)
        expect(page).to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'dt[data-attendance-on="2025-01-15"]', text: '01/15'
        expect(page).not_to have_selector 'dt[data-attendance-on="2025-02-05"]', text: '02/15'
      end

      scenario 'attendances during the hibernated period are not displayed', :js do
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 1, 15), course: rails_course)
        FactoryBot.create(:meeting, date: Time.zone.local(2025, 2, 5), course: rails_course)
        FactoryBot.create(:hibernation, finished_at: Time.zone.local(2025, 1, 31), member:, created_at: Time.zone.local(2025, 1, 10))

        visit member_path(member)
        expect(page).to have_selector 'div[data-attendance-table="1"]'
        expect(page).to have_selector 'div[data-attendance-table="2"]'

        within('div[data-attendance-table="1"]') do
          expect(page).to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
          expect(page).not_to have_selector 'dt[data-attendance-on="2025-01-15"]', text: '01/15'
        end
        within('div[data-attendance-table="2"]') do
          expect(page).to have_selector 'dt[data-attendance-on="2025-02-05"]', text: '02/05'
          expect(page).not_to have_selector 'dt[data-attendance-on="2025-01-15"]', text: '01/15'
        end
      end

      scenario 'show message if the member have not yet attended meeting' do
        visit member_path(member)
        expect(page).to have_content 'aliceさんはまだミーティングに出席していません'
      end
    end
  end

  describe 'show members' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:front_end_course) { FactoryBot.create(:front_end_course) }
    let!(:member) { FactoryBot.create(:member, course: rails_course) }

    scenario 'list members by course' do
      FactoryBot.create_list(:member, 10, :sample_member, course: rails_course)
      front_end_member = FactoryBot.create(:member, :another_member, course: front_end_course)

      login_as member
      visit course_members_path(rails_course)
      within('#course_tab') do
        expect(page).to have_link 'Railsエンジニアコース'
        expect(page).to have_link 'フロントエンドエンジニアコース'
      end
      rails_course.members.each do |member|
        within("li[data-member='#{member.id}']") do
          expect(page).to have_link member.name, href: member_path(member)
          expect(page).to have_selector "img[src='#{member.avatar_url}']"
          expect(page).not_to have_link 'チームメンバーから外す'
        end
      end
      expect(page).not_to have_link 'bob', href: member_path(front_end_member)

      within('#course_tab') do
        click_link 'フロントエンドエンジニアコース'
      end
      rails_course.members.each do |member|
        expect(page).not_to have_link member.name, href: member_path(member)
      end
      expect(page).to have_link 'bob', href: member_path(front_end_member)
      expect(page).to have_selector "img[src='#{front_end_member.avatar_url}']"
    end

    scenario 'member\'s recent attendances are also displayed' do
      create_meetings(course: rails_course, first_meeting_date: Time.zone.local(2025, 1, 1), count: 13)
      member.update!(created_at: Time.zone.local(2024, 12, 31))
      another_member = FactoryBot.create(:member, :another_member, course: rails_course, created_at: Time.zone.local(2025, 4, 1))
      rails_course.meetings.each do |meeting|
        FactoryBot.create(:attendance, member:, meeting:) if member.created_at.before?(meeting.date)
        FactoryBot.create(:attendance, :night, member: another_member, meeting:) if another_member.created_at.before?(meeting.date)
      end

      login_as member
      visit course_members_path(rails_course)
      within("li[data-member='#{member.id}']") do
        expect(page).to have_selector 'dt[data-attendance-on]', count: 12
        expect(page).to have_selector 'dd[data-attendance-on]', count: 12
        expect(page).not_to have_selector 'dt[data-attendance-on="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'dt[data-attendance-on="2025-01-15"]', text: '01/15'
        expect(page).to have_selector 'dd[data-attendance-on="2025-01-15"]', text: '昼'
        expect(page).to have_selector 'dt[data-attendance-on="2025-07-02"]', text: '07/02'
        expect(page).to have_selector 'dd[data-attendance-on="2025-07-02"]', text: '昼'
      end
      within("li[data-member='#{another_member.id}']") do
        expect(page).to have_selector 'dt[data-attendance-on]', count: 7
        expect(page).to have_selector 'dd[data-attendance-on]', count: 7
        expect(page).not_to have_selector 'dt[data-attendance-on="2025-03-19"]', text: '03/19'
        expect(page).to have_selector 'dt[data-attendance-on="2025-04-02"]', text: '04/02'
        expect(page).to have_selector 'dd[data-attendance-on="2025-04-02"]', text: '夜'
        expect(page).to have_selector 'dt[data-attendance-on="2025-07-02"]', text: '07/02'
        expect(page).to have_selector 'dd[data-attendance-on="2025-07-02"]', text: '夜'
      end
    end

    scenario 'show message if the member have not yet attended meeting' do
      login_as member
      visit course_members_path(rails_course)
      within("li[data-member='#{member.id}']") do
        expect(page).to have_content 'aliceさんはまだミーティングに出席していません'
      end
    end

    context 'when logged in as member' do
      scenario 'view only active member' do
        hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
        FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 1, 1))

        login_as member
        visit course_members_path(rails_course)
        expect(page).not_to have_selector 'div#status_tab'
        expect(page).to have_link member.name, href: member_path(member)
        expect(page).not_to have_link hibernated_member.name, href: member_path(hibernated_member)

        visit course_members_path(rails_course, status: 'hibernated')
        expect(page).to have_link member.name, href: member_path(member)
        expect(page).not_to have_link hibernated_member.name, href: member_path(hibernated_member)
      end
    end

    context 'when logged in as admin' do
      scenario 'view active member and all member' do
        hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
        FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 1, 1))

        login_as_admin FactoryBot.create(:admin)
        visit course_members_path(rails_course)
        within('#status_tab') do
          expect(page).to have_link '現役', href: course_members_path(rails_course, status: 'active')
          expect(page).to have_link '全て', href: course_members_path(rails_course, status: 'all')
        end

        within('#status_tab') do
          click_link '現役'
        end
        expect(page).to have_content 'alice'
        expect(page).not_to have_content hibernated_member.name

        within('#status_tab') do
          click_link '全て'
        end
        expect(page).to have_content 'alice'
        within("li[data-member='#{hibernated_member.id}']") do
          expect(page).to have_content hibernated_member.name
          expect(page).to have_content '離脱中'
        end
      end

      scenario 'can make member hibernated' do
        login_as_admin FactoryBot.create(:admin)
        visit course_members_path(rails_course)
        within("li[data-member='#{member.id}']") do
          expect(page).to have_content 'alice'
          expect(page).not_to have_content '離脱中'
          expect(page).to have_link 'チームメンバーから外す'
          page.accept_confirm do
            click_link 'チームメンバーから外す'
          end
        end
        # expect(current_page)だとクエリ部分が無視されてしまうため、expect(page).to have_current_pathでテストする
        expect(page).to have_current_path(course_members_path(rails_course, status: 'all'))
        expect(page).to have_content 'aliceをチームメンバーから外しました'
        within("li[data-member='#{member.id}']") do
          expect(page).to have_content '離脱中'
          expect(page).not_to have_link 'チームメンバーから外す'
        end
      end

      scenario 'cannot make member hibernated who already hibernated' do
        login_as_admin FactoryBot.create(:admin)
        visit course_members_path(rails_course)

        FactoryBot.create(:hibernation, member:)
        within("li[data-member='#{member.id}']") do
          page.accept_confirm do
            click_link 'チームメンバーから外す'
          end
        end
        expect(page).to have_current_path(course_members_path(rails_course, status: 'all'))
        expect(page).to have_content 'aliceさんはすでにチームメンバーから外れています'
      end
    end
  end
end
