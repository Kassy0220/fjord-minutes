# frozen_string_literal: true

module ApplicationHelper
  def build_meta_tags(title: nil, description: nil)
    page_title = title.nil? ? 'Fjord Minutes' : "#{title} | Fjord Minutes"
    { title: page_title, description:, keywords: 'チーム開発ミーティング, 議事録, フィヨルドブートキャンプ, FBC' }
  end
end
