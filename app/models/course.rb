class Course < ApplicationRecord
  enum :meeting_week, [ :odd, :even ], suffix: true

  has_many :minutes, dependent: :destroy
end
