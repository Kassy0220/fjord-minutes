# frozen_string_literal: true

class Members::SessionsController < Devise::SessionsController
  # Devise::SessionsController#destroyを元に作成
  def destroy
    member = current_member
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    if signed_out
      set_flash_message! :notice, :signed_out
      member.hibernations.create!
    end
    respond_to_on_destroy
  end
end
