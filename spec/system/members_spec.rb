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
      expect(page).to have_link 'チーム開発を抜ける'

      visit member_path(another_member)
      expect(page).to have_selector 'h1', text: 'bobさんの出席一覧(フロントエンドエンジニアコース)'
      expect(page).not_to have_link 'チーム開発を抜ける'
    end

    context 'when display member attendances' do
      let(:rails_course) { FactoryBot.create(:rails_course) }
      let(:member) { FactoryBot.create(:member, course: rails_course) }

      before do
        login_as member
      end

      scenario 'attendance is listed', :js do
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
        expect(page).to have_selector 'span[data-table-head="2025-01-01"]', text: '01/01'
        expect(page).to have_selector 'span[data-table-data="2025-01-01"]', text: '昼'
        expect(page).to have_selector 'span[data-table-head="2025-01-15"]', text: '01/15'
        expect(page).to have_selector 'span[data-table-data="2025-01-15"]', text: '夜'
        expect(page).to have_selector 'span[data-table-head="2025-02-05"]', text: '02/05'
        expect(page).to have_selector 'span[data-table-data="2025-02-05"]', text: '欠席'
        expect(page).to have_selector 'span[data-table-head="2025-02-19"]', text: '02/19'
        expect(page).to have_selector 'span[data-table-data="2025-02-19"]', text: '---'

        expect(page).not_to have_selector 'div[data-testid="flowbite-tooltip"]', text: '体調不良のため。'
        find('span[data-table-data="2025-02-05"]').hover
        expect(page).to have_selector 'div[data-testid="flowbite-tooltip"]', text: '体調不良のため。'
      end

      scenario 'attendance is listed per year', :js do
        FactoryBot.create(:minute, meeting_date: Time.zone.local(2024, 12, 18), course: rails_course)
        FactoryBot.build_list(:minute, 2) do |minute|
          minute.meeting_date = MeetingDateCalculator.next_meeting_date(rails_course.minutes.last.meeting_date, rails_course.meeting_week)
          minute.course = rails_course
          minute.save!
        end
        rails_course.minutes.each { |minute| FactoryBot.create(:attendance, member:, minute:) }

        visit member_path(member)
        expect(page).to have_selector 'div[data-attendances-year="2024"]'
        expect(page).to have_selector 'div[data-attendances-year="2025"]'

        within('div[data-attendances-year="2024"]') do
          expect(page).to have_selector 'span[data-table-head="2024-12-18"]', text: '12/18'
          expect(page).to have_selector 'span[data-table-data="2024-12-18"]', text: '昼'
        end
        within('div[data-attendances-year="2025"]') do
          expect(page).to have_selector 'span[data-table-head="2025-01-01"]', text: '01/01'
          expect(page).to have_selector 'span[data-table-data="2025-01-01"]', text: '昼'
          expect(page).to have_selector 'span[data-table-head="2025-01-15"]', text: '01/15'
          expect(page).to have_selector 'span[data-table-data="2025-01-15"]', text: '昼'
        end
      end
    end
  end
end
