class API::Minutes::TopicsController < API::Minutes::ApplicationController
  def create
    topic = @minute.topics.new(topic_params)
    if topic.save
      render json: @minute, status: :created
      broadcast_to_channel
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    topic = @minute.topics.find(params[:id])
    if topic.update(topic_params)
      render json: topic, status: :ok
      broadcast_to_channel
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    topic = @minute.topics.find(params[:id])
    topic.destroy!

    head :no_content
    broadcast_to_channel
  end

  private

  def topic_params
    params.require(:topic).permit(:content)
  end

  def broadcast_to_channel
    MinuteChannel.broadcast_to(@minute, body: { topics: @minute.topics.order(:created_at).as_json(only: [ :id, :content ]) })
  end
end
