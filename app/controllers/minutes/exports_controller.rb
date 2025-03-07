# frozen_string_literal: true

class Minutes::ExportsController < Minutes::ApplicationController
  before_action :authenticate_admin!

  def create
    current_admin.github_credential.update_access_token if current_admin.github_credential.expired?

    MinuteGithubExporter.export_to_github_wiki(@minute, current_admin.github_credential.access_token)
    @minute.update!(exported: true) unless @minute.exported?
    redirect_to course_minutes_path(@minute.course), notice: 'GitHub Wikiに議事録を反映させました'
  end
end
