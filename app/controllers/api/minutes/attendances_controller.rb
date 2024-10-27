# frozen_string_literal: true

class API::Minutes::AttendancesController < API::Minutes::ApplicationController
  def index
    @attendances = @minute.attendances.includes(:member).order(:member_id)
    # 休止機能を実装した際、無断欠席者から休止者は除外するようにする
    @unexcused_absentees = Member.where(course_id: @minute.course_id).where.not(id: @attendances.pluck(:member_id)).order(:id)
  end
end
