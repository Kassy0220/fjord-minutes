# frozen_string_literal: true

class Course < ApplicationRecord
  enum :meeting_week, { odd: 0, even: 1 }, suffix: true

  has_many :minutes, dependent: :restrict_with_exception
  has_many :members, dependent: :restrict_with_exception
end
