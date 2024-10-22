class Minute < ApplicationRecord
  belongs_to :course
  has_many :topics, dependent: :destroy
  has_many :attendances

  def already_finished?
    meeting_date.before?(Time.zone.today)
  end
end
