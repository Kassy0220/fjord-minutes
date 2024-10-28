# frozen_string_literal: true

class Minutes::ExportsController < Minutes::ApplicationController
  before_action :authenticate_admin!

  def create
    GithubWikiManager.export_minute(@minute)
    @minute.update!(exported: true) unless @minute.exported?
    redirect_to minutes_path, notice: 'GitHub Wikiに議事録を反映させました'
  end
end
