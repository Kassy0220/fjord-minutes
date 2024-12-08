# frozen_string_literal: true

module ApplicationHelper
  def page_title(description)
    "#{description} | Fjord Minutes"
  end

  def build_meta_tags(description)
    { description:, keywords: 'チーム開発ミーティング, 議事録, フィヨルドブートキャンプ, FBC' }
  end
end
