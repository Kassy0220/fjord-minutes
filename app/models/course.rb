class Course < ApplicationRecord
  enum :meeting_week, [ :odd, :even ], suffix: true
end
