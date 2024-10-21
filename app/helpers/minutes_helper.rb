module MinutesHelper
  def minute_title(minute)
    "ふりかえり・計画ミーティング#{minute.meeting_date.strftime('%Y年%m月%d日')}"
  end
end
