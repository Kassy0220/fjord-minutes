class API::Minutes::TopicsController < API::Minutes::ApplicationController
  def create
    if @minute.topics.create(topic_params)
      render json: @minute, status: :created
    else
      render json: { errors: @minute.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:content)
  end
end
