class API::Minutes::TopicsController < API::Minutes::ApplicationController
  def create
    topic = @minute.topics.new(topic_params)
    if topic.save
      render json: @minute, status: :created
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    topic = @minute.topics.find(params[:id])
    if topic.update(topic_params)
      render json: topic, status: :ok
    else
      render json: { errors: topic.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    topic = @minute.topics.find(params[:id])
    topic.destroy!

    head :no_content
  end

  private

  def topic_params
    params.require(:topic).permit(:content)
  end
end
