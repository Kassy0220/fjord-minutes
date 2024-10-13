class Attendance < ApplicationRecord
  enum :status, [ :present, :absent ]
  enum :time, [ :day, :night ], suffix: true

  belongs_to :minute
  belongs_to :member

  validates :status, presence: true
  validates :time, presence: true, if: Proc.new { |attendance| attendance.present? }
  validates :absence_reason, presence: true, if: Proc.new { |attendance| attendance.absent? }
  validates :progress_report, presence: true, if: Proc.new { |attendance| attendance.absent? }
end
