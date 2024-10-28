# frozen_string_literal: true

module MinutesHelper
  def github_wiki_url(minute)
    repository_url = minute.course.name == 'Railsエンジニアコース' ? ENV.fetch('BOOTCAMP_WIKI_URL', nil) : ENV.fetch('AGENT_WIKI_URL', nil)
    URI.join(repository_url.sub('.wiki.git', '/wiki/'), URI.encode_www_form_component(minute.title)).to_s
  end
end
