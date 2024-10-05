class API::Minutes::ApplicationController < API::BaseController
  before_action :set_minute

  private

  def set_minute
    @minute = Minute.find(params[:minute_id])
  end
end
