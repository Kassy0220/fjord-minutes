# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :recoverable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :topics, as: :topicable, dependent: :destroy

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |member|
      member.email = auth.info.email
      member.name = auth.info.nickname
      member.avatar_url = auth.info.image
      member.password = Devise.friendly_token[0, 20]
    end
  end
end
