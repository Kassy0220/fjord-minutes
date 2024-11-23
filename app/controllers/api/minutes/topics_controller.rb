# frozen_string_literal: true

class API::Minutes::TopicsController < API::Minutes::ApplicationController
  def create
    topic = current_development_member.topics.new(topic_params)
    topic.minute_id = @minute.id
    if topic.save
      render json: @minute, status: :created
      broadcast_to_channel
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    topic = current_development_member.topics.find(params[:id])
    if topic.update(topic_params)
      render json: topic, status: :ok
      broadcast_to_channel
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    topic = current_development_member.topics.find(params[:id])
    topic.destroy!

    head :no_content
    broadcast_to_channel
  end

  private

  def topic_params
    params.require(:topic).permit(:content)
  end

  def broadcast_to_channel
    topics = Topic.includes(:topicable).where(minute: @minute).order(:created_at)
    MinuteChannel.broadcast_to(@minute,
                               body: { topics: topics.as_json(only: %i[id content topicable_id topicable_type], include: { topicable: { only: [:name] } }) })
  end
end
