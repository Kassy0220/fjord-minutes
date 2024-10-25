class Minutes::ExportsController < Minutes::ApplicationController
  before_action :authenticate_admin!

  def create
    GithubWikiManager.export_minute(@minute)
    redirect_to minutes_path, notice: "GitHub Wikiに議事録を反映させました"
  end
end
