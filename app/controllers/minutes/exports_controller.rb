# frozen_string_literal: true

class Minutes::ExportsController < Minutes::ApplicationController
  before_action :authenticate_admin!

  def create
    @minute.export_to_github_wiki
    @minute.update!(exported: true) unless @minute.exported?
    redirect_to course_minutes_path(@minute.course), notice: t('.success')
  end
end
