class MinuteChannel < ApplicationCable::Channel
  def subscribed
    minute = Minute.find(params[:id])
    stream_for minute
  end
end
