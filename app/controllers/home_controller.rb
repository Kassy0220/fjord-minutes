# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_development_member!, only: [:index]

  def index
    if current_development_member
      if admin_login?
        @courses = Course.includes(:minutes).order(:id)
        render 'admin_dashboard'
      else
        @member = current_development_member
        render 'members/show'
      end
    else
      render 'index'
    end
  end
end
