# frozen_string_literal: true

class AuthenticationsController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    Rails.logger.info "request.env : #{request.env['omniauth.auth']}"
    @member_or_admin = if admin?(request.env['omniauth.auth'].info.email)
                         Admin.from_omniauth(request.env['omniauth.auth'])
                       else
                         Member.from_omniauth(request.env['omniauth.auth'], request.env['omniauth.params'])
                       end

    if @member_or_admin.persisted?
      sign_in_and_redirect @member_or_admin
      remember_me @member_or_admin
      if admin_signed_in? || !@member_or_admin.hibernated?
        set_flash_message(:notice, :success, kind: 'GitHub')
        return
      end

      @member_or_admin.hibernations.last.update!(finished_at: Time.zone.today)
      set_flash_message(:notice, :success_with_hibernation)
    else
      session['devise.github_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path, alert: t('.failure')
  end

  private

  def admin?(email)
    admin_emails = [ENV.fetch('KOMAGATA_EMAIL', 'no_email'), ENV.fetch('MACHIDA_EMAIL', 'no_email'), ENV.fetch('KASSY_EMAIL', 'no_email')]
    admin_emails.include? email
  end
end
