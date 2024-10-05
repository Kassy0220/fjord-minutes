class API::MinutesController < API::BaseController
  def update
    minute = Minute.find(params[:id])

    if minute.update(minute_params)
      render json: minute, status: :ok
    else
      render json: { errors: minute.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def minute_params
    params.require(:minute).permit(:release_branch, :release_note, :other, :next_meeting_date)
  end
end
