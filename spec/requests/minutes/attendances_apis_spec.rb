# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Minutes::Attendances API', type: :request do
  let(:rails_course) { FactoryBot.create(:rails_course) }
  let(:meeting) { FactoryBot.create(:meeting, course: rails_course) }
  let(:alice) { FactoryBot.create(:member, course: rails_course) }
  let(:bob) { FactoryBot.create(:member, :another_member, course: rails_course) }
  let(:absent_member) { FactoryBot.create(:member, :absent_member, course: rails_course) }

  before do
    FactoryBot.create(:attendance, member: alice, meeting:)
    FactoryBot.create(:attendance, :night, member: bob, meeting:)
    FactoryBot.create(:attendance, :absence, member: absent_member, meeting:)
    sign_in alice
  end

  it 'return attendees and absentees' do
    unexcused_absentee = FactoryBot.create(:member, :unexcused_absent_member, course: rails_course)
    expected_data = {
      afternoon_attendees: [{ attendance_id: alice.attendances.first.id, member_id: alice.id, name: 'alice' }],
      night_attendees: [{ attendance_id: bob.attendances.first.id, member_id: bob.id, name: 'bob' }],
      absentees: [{ attendance_id: absent_member.attendances.first.id,
                    member_id: absent_member.id,
                    name: 'absentee',
                    absence_reason: '体調不良のため。',
                    progress_report: 'PRのチームメンバーのレビューが通り、komagataさんにレビュー依頼をお願いしているところです。' }],
      unexcused_absentees: [{ member_id: unexcused_absentee.id, name: 'unexcused_absentee' }]
    }.as_json
    get api_meeting_attendances_path(meeting), headers: { 'Content-Type' => 'application/json' }, as: :json
    expect(response).to have_http_status(:success)
    expect(response.parsed_body).to eq expected_data
  end
end
