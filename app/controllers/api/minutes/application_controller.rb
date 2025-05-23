# frozen_string_literal: true

class API::Minutes::ApplicationController < API::ApplicationController
  before_action :set_minute

  private

  def set_minute
    @minute = Minute.find(params[:minute_id])
  end
end
