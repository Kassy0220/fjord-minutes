# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_development_member!, only: [:index]

  def index
    if current_development_member
      template = admin_login? ? 'admin_dashboard' : 'member_dashboard'
      render template
    else
      render 'index'
    end
  end
end
