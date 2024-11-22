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
    join_query = "LEFT JOIN (SELECT * FROM attendances WHERE member_id = #{id}) AS attendances ON minutes.id = attendances.minute_id"
    target_period = hibernated? ? (created_at..hibernations.last.created_at) : (created_at..)
    attendances = Minute.joins(join_query)
                        .where(course_id:)
                        .where(meeting_date: target_period)
                        .order(:meeting_date)
                        .pluck(:id, :meeting_date, attendances: %i[status time absence_reason])
                        .map { |data| { minute_id: data[0], date: data[1], status: data[2], time: data[3], absence_reason: data[4] } }
    was_hibernated? ? remove_hibernated_period(attendances) : attendances
  end

  private

  def was_hibernated?
    hibernations.where.not(finished_at: nil).any?
  end

  def remove_hibernated_period(attendances)
    hibernated_periods = hibernations.where.not(finished_at: nil).map { |hibernation| hibernation.created_at.to_date..hibernation.finished_at }
    attendances.reject do |attendance|
      hibernated_periods.any? { |period| period.cover?(attendance[:date]) }
    end
  end
end
