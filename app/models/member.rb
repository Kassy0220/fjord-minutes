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

  scope :active, -> { where.not(id: hibernated.pluck(:id)) }
  scope :hibernated, -> { joins(:hibernations).where(hibernations: { finished_at: nil }) }

  def self.from_omniauth(auth, params)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |member|
      member.email = auth.info.email
      member.name = auth.info.nickname
      member.avatar_url = auth.info.image
      member.password = Devise.friendly_token[0, 20]
      member.course_id = params['course_id'].to_i
    end
  end

  def admin?
    false
  end

  def hibernated?
    hibernations.where(finished_at: nil).any?
  end

  def all_attendances
    join_query = "LEFT JOIN (SELECT * FROM attendances WHERE member_id = #{id}) AS attendances ON minutes.id = attendances.minute_id"
    Minute.joins(join_query)
          .where(course_id:)
          .where(meeting_date: created_at..)
          .order(:meeting_date)
          .pluck(:meeting_date, attendances: %i[id status time absence_reason])
          .map { |minute| { date: minute[0], attendance_id: minute[1], status: minute[2], time: minute[3], absence_reason: minute[4] } }
  end
end
