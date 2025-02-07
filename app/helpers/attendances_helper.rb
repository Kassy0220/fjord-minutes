# frozen_string_literal: true

module AttendancesHelper
  def split_attendances(attendances, member)
    # 以下の条件で出席を分割する
    # 1. 年ごとに分割
    # 2. チームメンバーが過去にチーム開発を離脱していた場合、離脱期間内の出席とそうでない出席を分割し、離脱期間内の出席は削除
    # 3. 出席を半年分(12回)ごとに分割
    attendances_by_year = attendances.group_by { |attendance| attendance[:date].year }
    attendances_by_year.transform_values do |annual_attendances|
      hibernation_periods = member.hibernations.where.not(finished_at: nil).map { |hibernation| hibernation.created_at.to_date..hibernation.finished_at }
      attendances_outside_of_hibernation_period = annual_attendances.chunk do |attendance|
        hibernation_periods.any? { |period| period.cover?(attendance[:date]) } ? nil : false
      end
      attendances_outside_of_hibernation_period.flat_map { |chunked_attendances| chunked_attendances[1].each_slice(12).to_a }
    end
  end

  def attendance_status(present, time)
    return '---' if present.nil?

    { 'afternoon' => '昼', 'night' => '夜' }[time]
  end
end
