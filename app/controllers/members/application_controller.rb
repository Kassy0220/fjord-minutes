# frozen_string_literal: true

class Members::ApplicationController < ApplicationController
  before_action :set_member

  private

  def set_member
    @member = Member.find(params[:member_id])
  end
end
