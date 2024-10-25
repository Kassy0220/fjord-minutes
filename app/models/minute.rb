class Minute < ApplicationRecord
  belongs_to :course
  has_many :topics, dependent: :destroy
  has_many :attendances

  def already_finished?
    meeting_date.before?(Time.zone.today)
  end

  def title
    "ふりかえり・計画ミーティング#{meeting_date.strftime('%Y年%m月%d日')}"
  end
end
