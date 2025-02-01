# frozen_string_literal: true

class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  belongs_to :course
  has_many :attendances, dependent: :destroy
  has_many :topics, as: :topicable, dependent: :destroy
  has_many :hibernations, dependent: :destroy

  scope :active, -> { where.not('EXISTS(SELECT 1 FROM hibernations WHERE member_id = members.id AND finished_at IS NULL)') }

  def self.from_omniauth(auth, params)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |member|
      member.email = auth.info.email
      member.name = auth.info.nickname
      member.avatar_url = auth.info.image
      member.password = Devise.friendly_token[0, 20]
      member.course_id = params['course_id'].to_i
    end
  end

  def hibernated?
    hibernations.where(finished_at: nil).any?
  end

  def all_attendances
    attendances = hibernated? ? attendance_list(to: hibernations.last.created_at) : attendance_list
    attendances_by_year = attendances.group_by { |attendance| attendance[:date].year }
    attendances_by_year.transform_values do |annual_attendances|
      split_for_display(annual_attendances)
    end
  end

  def recent_attendances
    from = was_hibernated? ? hibernations.where.not(finished_at: nil).last.finished_at : created_at
    to = hibernated? ? hibernations.last.created_at : nil
    attendance_list(from:, to:).pop(12)
  end

  private

  def attendance_list(from: created_at, to: nil)
    Minute.joins("LEFT JOIN (SELECT * FROM attendances WHERE member_id = #{id}) AS attendances ON minutes.id = attendances.minute_id")
          .where(course_id:)
          .where(meeting_date: from..to)
          .order(:meeting_date)
          .pluck(:id, :meeting_date, attendances: %i[id present session absence_reason])
          .map { |data| { minute_id: data[0], date: data[1], attendance_id: data[2], present: data[3], session: data[4], absence_reason: data[5] } }
  end

  def split_for_display(attendances)
    # 以下の条件で出席を分割する
    # 1. 離脱期間が含まれる場合は、離脱期間に含まれる出席と含まれない出席を分割し、離脱期間に含まれる出席は削除する
    # 2. 出席を半年分(12回)ごとに分割する
    hibernation_periods = hibernations.where.not(finished_at: nil).map { |hibernation| hibernation.created_at.to_date..hibernation.finished_at }
    attendances_without_hibernation_period = attendances.chunk do |attendance|
      hibernation_periods.any? { |period| period.cover?(attendance[:date]) } ? nil : false
    end
    attendances_without_hibernation_period.flat_map { |v| v[1].each_slice(12).to_a }
  end

  def was_hibernated?
    hibernations.where.not(finished_at: nil).any?
  end
end
