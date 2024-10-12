class Attendance < ApplicationRecord
  enum :status, [ :present, :absent ]
  enum :time, [ :day, :night ], suffix: true

  belongs_to :minute
  belongs_to :member
end
