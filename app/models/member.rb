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
    Meeting.joins(ActiveRecord::Base.sanitize_sql_array(['LEFT JOIN attendances ON meetings.id = attendances.meeting_id AND attendances.member_id = ?', id]))
           .where(course_id:)
           .where(date: from..to)
           .order(:date)
           .pluck(:id, :date, attendances: %i[id attended session absence_reason])
           .map { |row| { meeting_id: row[0], date: row[1], attendance_id: row[2], attended: row[3], session: row[4], absence_reason: row[5] } }
  end

  def was_hibernated?
    hibernations.where.not(finished_at: nil).exists?
  end
end
