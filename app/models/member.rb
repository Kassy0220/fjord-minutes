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
    hibernations.exists?(finished_at: nil)
  end

  def all_attendances
    hibernated? ? attendance_records(to: hibernations.last.created_at) : attendance_records
  end

  def recent_attendances
    from = was_hibernated? ? hibernations.where.not(finished_at: nil).last.finished_at : created_at
    to = hibernated? ? hibernations.last.created_at : nil
    attendance_records(from:, to:).pop(12)
  end

  private

  def attendance_records(from: created_at, to: nil)
    Meeting.joins("LEFT JOIN (SELECT * FROM attendances WHERE member_id = #{id}) AS attendances ON meetings.id = attendances.meeting_id")
           .where(course_id:)
           .where(date: from..to)
           .order(:date)
           .pluck(:id, :date, attendances: %i[id present session absence_reason])
           .map { |data| { meeting_id: data[0], date: data[1], attendance_id: data[2], present: data[3], session: data[4], absence_reason: data[5] } }
  end

  def was_hibernated?
    hibernations.where.not(finished_at: nil).exists?
  end
end
