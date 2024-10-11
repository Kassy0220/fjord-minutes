class AuthenticationsController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    @member = Member.from_omniauth(request.env["omniauth.auth"], request.env["omniauth.params"])

    if @member.persisted?
      sign_in_and_redirect @member
      remember_me @member
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to root_url
    end
  end

  # OmniAuthエラー時の処理は、Deviseで実装されている処理をそのまま追加
  # https://github.com/heartcombo/devise/blob/72884642f5700439cc96ac560ee19a44af5a2d45/app/controllers/devise/omniauth_callbacks_controller.rb#L6
  def passthru
    render status: 404, plain: "Not found. Authentication passthru."
  end

  def failure
    set_flash_message! :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to root_path
  end

  protected

  def failed_strategy
    request.respond_to?(:get_header) ? request.get_header("omniauth.error.strategy") : request.env["omniauth.error.strategy"]
  end

  def failure_message
    exception = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    error   = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error        if exception.respond_to?(:error)
    error ||= (request.respond_to?(:get_header) ? request.get_header("omniauth.error.type") : request.env["omniauth.error.type"]).to_s
    error.to_s.humanize if error
  end

  def translation_scope
    "devise.omniauth_callbacks"
  end
end
