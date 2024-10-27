# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  devise_group :development_member, contains: %i[member admin]
  before_action :authenticate_development_member!

  def after_sign_in_path_for
    root_path
  end

  private

  def admin_login?
    development_member_signed_in? && current_development_member.is_a?(Admin)
  end
end
