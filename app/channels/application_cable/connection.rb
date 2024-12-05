# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_development_member

    def connect
      development_member = find_development_member
      reject_unauthorized_connection unless development_member

      self.current_development_member = development_member
      Rails.logger.info("Action Cable connection from #{development_member.class}(id: #{development_member.id}) is established.")
    end

    def disconnect
      Rails.logger.info("Action Cable connection from #{current_development_member.class}(id: #{current_development_member.id}) is closed.")
    end

    private

    def find_development_member
      if cookies.signed[:remember_admin_token]
        Admin.serialize_from_cookie(*cookies.signed[:remember_admin_token])
      elsif cookies.signed[:remember_member_token]
        Member.serialize_from_cookie(*cookies.signed[:remember_member_token])
      else
        reject_unauthorized_connection
      end
    end
  end
end
