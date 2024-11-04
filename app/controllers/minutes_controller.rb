# frozen_string_literal: true

class MinutesController < ApplicationController
  skip_before_action :authenticate_development_member!, only: [:index]
  before_action :set_minute, only: %i[show edit]

  def index
    @minutes = Minute.all
  end

  def show; end

  def edit
    @topics = @minute.topics.order(:created_at)
  end

  private

  def set_minute
    @minute = Minute.find(params[:id])
  end
end
