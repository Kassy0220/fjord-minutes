# frozen_string_literal: true

class Meetings::ApplicationController < ApplicationController
  before_action :set_meeting

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end
