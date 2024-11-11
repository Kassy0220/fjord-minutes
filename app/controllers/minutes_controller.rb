# frozen_string_literal: true

class MinutesController < ApplicationController
  before_action :set_minute, only: %i[show edit]

  def show; end

  def edit
    @topics = @minute.topics.order(:created_at)
  end

  private

  def set_minute
    @minute = Minute.find(params[:id])
  end
end
