# frozen_string_literal: true

class API::MinutesController < API::ApplicationController
  before_action :authenticate_admin!

  def update
    minute = Minute.find(params[:id])

    if minute.update(minute_params)
      render json: minute.as_json(root: 'minute', only: [:id]), status: :ok
      MinuteChannel.broadcast_to(minute, body: { minute: minute.as_json(only: %i[release_branch release_note other]) })
    else
      render json: { errors: minute.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def minute_params
    params.require(:minute).permit(:release_branch, :release_note, :other)
  end
end
