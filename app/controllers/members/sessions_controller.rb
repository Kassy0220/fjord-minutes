# frozen_string_literal: true

class Members::SessionsController < Devise::SessionsController
  # Devise::SessionsController#destroyを元に作成
  before_action :prohibit_logout_without_reason

  def destroy
    member = current_member
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      set_flash_message! :notice, :signed_out
      member.update!(completed_at: Time.zone.today) if params[:reason] == 'completed'
      member.hibernations.create!
    end
    respond_to_on_destroy
  end

  private

  def prohibit_logout_without_reason
    return unless params[:reason].nil?

    redirect_to root_path, alert: t('errors.messages.without_reason')
  end
end
