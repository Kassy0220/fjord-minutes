# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :authenticate_admin!

  def create
    current_admin.initialize_github_credential(params['code'])
    minute = Minute.find(params['state'])
    MinuteGithubExporter.export_to_github_wiki(minute, current_admin.name, current_admin.github_credential.access_token)
    minute.update!(exported: true) unless minute.exported?
    redirect_to course_minutes_path(minute.course), notice: t('.success')
  end
end
