# frozen_string_literal: true

class Attendance < ApplicationRecord
  enum :session, { afternoon: 0, night: 1 }, suffix: true

  belongs_to :meeting
  belongs_to :member
  has_one :minute, through: :meeting

  scope :at_afternoon_session, -> { where(session: :afternoon) }
  scope :at_night_session, -> { where(session: :night) }
  scope :absent, -> { where(attended: false) }
  scope :with_members, -> { includes(:member) }

  validates :attended, inclusion: { in: [true, false] }
  validates :session, presence: true, if: proc { |attendance| attendance.attended? }
  validates :session, absence: true, unless: proc { |attendance| attendance.attended? }
  validates :absence_reason, presence: true, unless: proc { |attendance| attendance.attended? }
  validates :progress_report, presence: true, unless: proc { |attendance| attendance.attended? }
  validates :absence_reason, absence: true, if: proc { |attendance| attendance.attended? }
  validates :progress_report, absence: true, if: proc { |attendance| attendance.attended? }
end
