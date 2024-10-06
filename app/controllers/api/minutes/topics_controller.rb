class API::Minutes::TopicsController < API::Minutes::ApplicationController
  def create
    topic = @minute.topics.new(topic_params)
    if topic.save
      render json: @minute, status: :created
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:content)
  end
end
