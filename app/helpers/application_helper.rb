# frozen_string_literal: true

module ApplicationHelper
  def build_meta_tags(title: nil, description: nil)
    page_title = title.nil? ? 'Fjord Minutes' : "#{title} | Fjord Minutes"
    {
      title: page_title,
      description:,
      keywords: 'チーム開発ミーティング, 議事録, フィヨルドブートキャンプ, FBC',
      og: {
        url: 'https://fjord-minutes-eded74419c61.herokuapp.com',
        type: 'website',
        title: page_title,
        description:,
        site_name: 'Fjord Minutes',
        image: image_url('ogp_image.png')
      },
      twitter: {
        card: 'summary',
        site: '@cassy0220',
        domain: 'https://fjord-minutes-eded74419c61.herokuapp.com'
      }
    }
  end
end
