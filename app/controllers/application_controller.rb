# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  devise_group :development_member, contains: %i[member admin]
  before_action :authenticate_development_member!
  before_action :prohibit_hibernated_member_access

  def after_sign_in_path_for(_resource)
    root_path
  end

  private

  def prohibit_hibernated_member_access
    return unless member_signed_in? && current_member.hibernated?

    sign_out
    redirect_to root_path, alert: t('errors.messages.hibernated_member_access')
  end
end
