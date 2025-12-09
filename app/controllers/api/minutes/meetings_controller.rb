# frozen_string_literal: true

class API::Minutes::MeetingsController < API::Minutes::ApplicationController
  before_action :authenticate_admin!

  def update
    meeting = Meeting.find(params[:id])
    if meeting.update(meeting_params)
      render json: meeting.as_json(root: 'meeting', only: [:id]), status: :ok
      MinuteChannel.broadcast_to(@minute, body: { meeting: meeting.as_json(only: %i[next_date]) })
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:next_date)
  end
end
