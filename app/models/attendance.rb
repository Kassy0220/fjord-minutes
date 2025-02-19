# frozen_string_literal: true

class Attendance < ApplicationRecord
  enum :session, { afternoon: 0, night: 1 }, suffix: true

  belongs_to :minute
  belongs_to :member

  validates :present, inclusion: { in: [true, false] }
  validates :session, presence: true, if: proc { |attendance| attendance.present? }
  validates :session, absence: true, unless: proc { |attendance| attendance.present? }
  validates :absence_reason, presence: true, unless: proc { |attendance| attendance.present? }
  validates :progress_report, presence: true, unless: proc { |attendance| attendance.present? }
  validates :absence_reason, absence: true, if: proc { |attendance| attendance.present? }
  validates :progress_report, absence: true, if: proc { |attendance| attendance.present? }
end
