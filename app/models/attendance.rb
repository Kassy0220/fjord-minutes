# frozen_string_literal: true

class Attendance < ApplicationRecord
  enum :status, { present: 0, absent: 1 }
  enum :time, { day: 0, night: 1 }, suffix: true

  belongs_to :minute
  belongs_to :member

  validates :status, presence: true
  validates :time, presence: true, if: proc { |attendance| attendance.present? }
  validates :time, absence: true, if: proc { |attendance| attendance.absent? }
  validates :absence_reason, presence: true, if: proc { |attendance| attendance.absent? }
  validates :progress_report, presence: true, if: proc { |attendance| attendance.absent? }
  validates :absence_reason, absence: true, if: proc { |attendance| attendance.present? }
  validates :progress_report, absence: true, if: proc { |attendance| attendance.present? }
end
