class HomeController < ApplicationController
  def index
    if current_member
      render "member_dashboard"
    else
      render "index"
    end
  end
end
