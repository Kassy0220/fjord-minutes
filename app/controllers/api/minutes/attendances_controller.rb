class API::Minutes::AttendancesController < API::Minutes::ApplicationController
  def index
    @attendances = @minute.attendances.includes(:member)
  end
end
