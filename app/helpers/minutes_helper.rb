# frozen_string_literal: true

module MinutesHelper
  def github_wiki_url(minute)
    URI.join(minute.course.wiki_repository_url.sub('.wiki.git', '/wiki/'), URI.encode_www_form_component(minute.title)).to_s
  end
end
