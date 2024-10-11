class HomeController < ApplicationController
  def index
    if current_development_member
      template = admin_login? ? "admin_dashboard" : "member_dashboard"
      render template
    else
      render "index"
    end
  end
end
