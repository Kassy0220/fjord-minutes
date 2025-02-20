# frozen_string_literal: true

class Minute < ApplicationRecord
  belongs_to :course
  has_many :topics, dependent: :destroy
  has_many :attendances, dependent: :destroy

  def already_finished?
    meeting_date.before?(Time.zone.today)
  end

  def title
    "ふりかえり・計画ミーティング#{I18n.l(meeting_date)}"
  end
end
