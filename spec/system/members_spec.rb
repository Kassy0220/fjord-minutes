# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Members', type: :system do
  context 'when show members' do
    scenario 'can access member show page' do
      rails_course = FactoryBot.create(:rails_course)
      front_end_course = FactoryBot.create(:front_end_course)
      member = FactoryBot.create(:member, course: rails_course)
      another_member = FactoryBot.create(:member, :another_member, course: front_end_course)

      login_as member
      visit member_path(member)
      expect(page).to have_selector 'h1', text: 'aliceさんの出席一覧(Railsエンジニアコース)'
      expect(page).to have_selector 'button.open_modal', text: 'チーム開発を抜ける'

      visit member_path(another_member)
      expect(page).to have_selector 'h1', text: 'bobさんの出席一覧(フロントエンドエンジニアコース)'
      expect(page).not_to have_selector 'button.open_modal', text: 'チーム開発を抜ける'
    end

    context 'when display member attendances' do
      let(:rails_course) { FactoryBot.create(:rails_course) }
      let(:member) { FactoryBot.create(:member, course: rails_course, created_at: Time.zone.local(2024, 12, 1)) }

      before do
        login_as member
      end

      scenario 'all attendances are listed', :js do
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.build_list(:minute, 3) do |minute|
          minute.meeting_date = MeetingDateCalculator.next_meeting_date(rails_course.minutes.last.meeting_date, rails_course.meeting_week)
          minute.course = rails_course
          minute.save!
        end
        FactoryBot.create(:attendance, member:, minute: rails_course.minutes.first)
        FactoryBot.create(:attendance, :night, member:, minute: rails_course.minutes.second)
        FactoryBot.create(:attendance, :absence, member:, minute: rails_course.minutes.third)

        visit member_path(member)
        expect(page).to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'div[data-table-body="2025-01-01"]', text: '昼'
        expect(page).to have_selector 'div[data-table-head="2025-01-15"]', text: '01/15'
        expect(page).to have_selector 'div[data-table-body="2025-01-15"]', text: '夜'
        expect(page).to have_selector 'div[data-table-head="2025-02-05"]', text: '02/05'
        expect(page).to have_selector 'div[data-table-body="2025-02-05"]', text: '欠席'
        expect(page).to have_selector 'div[data-table-head="2025-02-19"]', text: '02/19'
        expect(page).to have_selector 'div[data-table-body="2025-02-19"]', text: '---'

        expect(page).not_to have_selector 'div#tooltip_absence_reason', text: '体調不良のため。'
        within('div[data-table-body="2025-02-05"]') do
          find('span[data-tooltip-target="tooltip_absence_reason"]').hover
          expect(page).to have_selector 'div#tooltip_absence_reason', text: '体調不良のため。'
        end
      end

      scenario 'attendance is listed per year', :js do
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 12, 18), course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
        rails_course.minutes.each { |minute| FactoryBot.create(:attendance, member:, minute:) }

        visit member_path(member)
        expect(page).to have_selector 'div[data-meeting-year="2024"]'
        expect(page).to have_selector 'div[data-meeting-year="2025"]'

        within('div[data-meeting-year="2024"]') do
          expect(page).to have_selector 'div[data-table-head="2024-12-18"]', text: '12/18'
          expect(page).to have_selector 'div[data-table-body="2024-12-18"]', text: '昼'
        end
        within('div[data-meeting-year="2025"]') do
          expect(page).to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
          expect(page).to have_selector 'div[data-table-body="2025-01-01"]', text: '昼'
        end
      end

      scenario 'attendance is divided in half year', :js do
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.build_list(:minute, 12) do |minute|
          minute.meeting_date = MeetingDateCalculator.next_meeting_date(rails_course.minutes.last.meeting_date, rails_course.meeting_week)
          minute.course = rails_course
          minute.save!
        end
        rails_course.minutes.each { |minute| FactoryBot.create(:attendance, member:, minute:) }

        visit member_path(member)
        expect(page).to have_selector 'div[data-attendance-table="1"]'
        expect(page).to have_selector 'div[data-attendance-table="2"]'

        within('div[data-attendance-table="1"]') do
          expect(page).to have_selector 'div[data-table-head]', count: 12
          expect(page).to have_selector 'div[data-table-body]', count: 12
          expect(page).to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
          expect(page).to have_selector 'div[data-table-body="2025-01-01"]', text: '昼'
          expect(page).to have_selector 'div[data-table-head="2025-06-18"]', text: '06/18'
          expect(page).to have_selector 'div[data-table-body="2025-06-18"]', text: '昼'
        end
        within('div[data-attendance-table="2"]') do
          expect(page).to have_selector 'div[data-table-head]', count: 1
          expect(page).to have_selector 'div[data-table-body]', count: 1
          expect(page).to have_selector 'div[data-table-head="2025-07-02"]', text: '07/02'
          expect(page).to have_selector 'div[data-table-body="2025-07-02"]', text: '昼'
        end
      end

      scenario 'display attendances until the hibernation started if the member is hibernated', :js do
        hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 15), course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 2, 5), course: rails_course)
        FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 2, 1))

        visit member_path(hibernated_member)
        expect(page).to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'div[data-table-head="2025-01-15"]', text: '01/15'
        expect(page).not_to have_selector 'div[data-table-head="2025-02-05"]', text: '02/15'
      end

      scenario 'does not display attendances during the hibernated period', :js do
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 15), course: rails_course)
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 2, 5), course: rails_course)
        FactoryBot.create(:hibernation, finished_at: Time.zone.local(2025, 1, 31), member:, created_at: Time.zone.local(2025, 1, 10))

        visit member_path(member)
        expect(page).to have_selector 'div[data-attendance-table="1"]'
        expect(page).to have_selector 'div[data-attendance-table="2"]'

        within('div[data-attendance-table="1"]') do
          expect(page).to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
          expect(page).not_to have_selector 'div[data-table-head="2025-01-15"]', text: '01/15'
        end
        within('div[data-attendance-table="2"]') do
          expect(page).to have_selector 'div[data-table-head="2025-02-05"]', text: '02/05'
          expect(page).not_to have_selector 'div[data-table-head="2025-01-15"]', text: '01/15'
        end
      end

      scenario 'show as not attending meeting if the member have not yet attended meeting' do
        visit member_path(member)
        expect(page).to have_content 'aliceさんはまだミーティングに出席していません'
      end
    end
  end

  context 'when list members' do
    let!(:rails_course) { FactoryBot.create(:rails_course) }
    let(:front_end_course) { FactoryBot.create(:front_end_course) }
    let!(:member) { FactoryBot.create(:member, course: rails_course) }

    scenario 'list members by course' do
      FactoryBot.create_list(:member, 10, :sample_member, course: rails_course)
      front_end_member = FactoryBot.create(:member, :another_member, course: front_end_course)

      login_as member
      visit course_members_path(rails_course)
      expect(page).to have_link 'Railsエンジニアコース'
      expect(page).to have_link 'フロントエンドエンジニアコース'
      rails_course.members.each do |member|
        within("li[data-member='#{member.id}']") do
          expect(page).to have_link member.name, href: member_path(member)
          expect(page).to have_selector "img[src='#{member.avatar_url}']"
          expect(page).not_to have_selector 'button.open_modal', text: '休止中にする'
        end
      end
      expect(page).not_to have_link 'bob', href: member_path(front_end_member)

      click_link 'フロントエンドエンジニアコース'
      rails_course.members.each do |member|
        expect(page).not_to have_link member.name, href: member_path(member)
      end
      expect(page).to have_link 'bob', href: member_path(front_end_member)
      expect(page).to have_selector "img[src='#{front_end_member.avatar_url}']"
    end

    scenario 'member\'s last half year attendance is displayed' do
      FactoryBot.create(:minute, meeting_date: Time.zone.local(2025, 1, 1), course: rails_course)
      FactoryBot.build_list(:minute, 12) do |minute|
        minute.meeting_date = MeetingDateCalculator.next_meeting_date(rails_course.minutes.last.meeting_date, rails_course.meeting_week)
        minute.course = rails_course
        minute.save!
      end
      member.update!(created_at: Time.zone.local(2024, 12, 31))
      another_member = FactoryBot.create(:member, :another_member, course: rails_course, created_at: Time.zone.local(2025, 4, 1))
      rails_course.minutes.each do |minute|
        FactoryBot.create(:attendance, member:, minute:) if member.created_at.before?(minute.meeting_date)
        FactoryBot.create(:attendance, :night, member: another_member, minute:) if another_member.created_at.before?(minute.meeting_date)
      end

      login_as member
      visit course_members_path(rails_course)
      within("li[data-member='#{member.id}']") do
        expect(page).to have_selector 'div[data-table-head]', count: 12
        expect(page).to have_selector 'div[data-table-body]', count: 12
        expect(page).not_to have_selector 'div[data-table-head="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'div[data-table-head="2025-01-15"]', text: '01/15'
        expect(page).to have_selector 'div[data-table-body="2025-01-15"]', text: '昼'
        expect(page).to have_selector 'div[data-table-head="2025-07-02"]', text: '07/02'
        expect(page).to have_selector 'div[data-table-body="2025-07-02"]', text: '昼'
      end
      within("li[data-member='#{another_member.id}']") do
        expect(page).to have_selector 'div[data-table-head]', count: 7
        expect(page).to have_selector 'div[data-table-body]', count: 7
        expect(page).not_to have_selector 'div[data-table-head="2025-03-19"]', text: '03/19'
        expect(page).to have_selector 'div[data-table-head="2025-04-02"]', text: '04/02'
        expect(page).to have_selector 'div[data-table-body="2025-04-02"]', text: '夜'
        expect(page).to have_selector 'div[data-table-head="2025-07-02"]', text: '07/02'
        expect(page).to have_selector 'div[data-table-body="2025-07-02"]', text: '夜'
      end
    end

    scenario 'show as not attending meeting if the member have not yet attended meeting' do
      login_as member
      visit course_members_path(rails_course)
      within("li[data-member='#{member.id}']") do
        expect(page).to have_content 'aliceさんはまだミーティングに出席していません'
      end
    end

    scenario 'admin can view active member and all member' do
      hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
      FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 1, 1))

      admin = FactoryBot.create(:admin)
      login_as_admin admin
      visit course_members_path(rails_course)
      expect(page).to have_link '現役', href: course_members_path(rails_course, status: 'active')
      expect(page).to have_link '全て', href: course_members_path(rails_course, status: 'all')

      click_link '現役'
      expect(page).to have_content 'alice'
      expect(page).not_to have_content hibernated_member.name

      click_link '全て'
      expect(page).to have_content 'alice'
      within("li[data-member='#{hibernated_member.id}']") do
        expect(page).to have_content hibernated_member.name
        expect(page).to have_content '離脱中'
      end
    end

    scenario 'member can view only active member' do
      hibernated_member = FactoryBot.create(:member, :another_member, course: rails_course)
      FactoryBot.create(:hibernation, member: hibernated_member, created_at: Time.zone.local(2025, 1, 1))

      login_as member
      visit course_members_path(rails_course)
      expect(page).not_to have_link '現役', href: course_members_path(rails_course, status: 'active')
      expect(page).not_to have_link '全て', href: course_members_path(rails_course, status: 'all')
      expect(page).to have_content 'alice'
      expect(page).not_to have_content hibernated_member.name

      visit course_members_path(rails_course, status: 'hibernated')
      expect(page).to have_content 'alice'
      expect(page).not_to have_content hibernated_member.name
    end

    scenario 'admin can make member hibernated' do
      admin = FactoryBot.create(:admin)
      login_as_admin admin
      visit course_members_path(rails_course)
      expect do
        within("li[data-member='#{member.id}']") do
          expect(page).to have_content 'alice'
          expect(page).to have_selector 'button.open_modal', text: 'チームメンバーから外す'
          click_button 'チームメンバーから外す'
        end
        find('#accept_modal').click
      end.to change(member.hibernations, :count).by(1)
      # expect(current_page)だとクエリ部分が無視されてしまうため、expect(page).to have_current_pathでテストする
      expect(page).to have_current_path(course_members_path(rails_course, status: 'all'))
      expect(page).to have_content 'aliceをチームメンバーから外しました'
      expect(page).to have_content 'alice'
    end

    scenario 'admin cannot make member hibernated who already hibernated' do
      admin = FactoryBot.create(:admin)
      login_as_admin admin
      visit course_members_path(rails_course)

      FactoryBot.create(:hibernation, member:)
      expect do
        within("li[data-member='#{member.id}']") do
          click_button 'チームメンバーから外す'
        end
        find('#accept_modal').click
      end.not_to change(member.hibernations, :count)
      expect(page).to have_current_path(course_members_path(rails_course, status: 'all'))
      expect(page).to have_content 'aliceさんはすでにチームメンバーから外れています'
    end
  end
end
