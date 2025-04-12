# frozen_string_literal: true

class Meeting < ApplicationRecord
  belongs_to :course
  has_one :minute, dependent: :destroy
  has_many :attendances, dependent: :destroy

  def already_finished?
    date.before?(Time.zone.today)
  end
end
