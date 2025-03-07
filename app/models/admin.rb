# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :recoverable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :topics, as: :topicable, dependent: :destroy
  has_one :github_credential, dependent: :destroy

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |member|
      member.email = auth.info.email
      member.name = auth.info.nickname
      member.avatar_url = auth.info.image
      member.password = Devise.friendly_token[0, 20]
    end
  end

  def initialize_github_credential(code)
    params = {
      client_id: ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
      client_secret: ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
      code:
    }
    response = Net::HTTP.post(
      URI('https://github.com/login/oauth/access_token'),
      URI.encode_www_form(params),
      { Accept: 'application/json' }
    )

    raise "Error!, Status Code: #{response.code} #{response.message}, Response Body: #{response.body}" if response.code != '200'

    response_body = JSON.parse(response.body)
    raise "Error!, #{response_body['error']} : #{response_body['error_description']}" if response_body.key?('error')

    create_github_credential!(access_token: response_body['access_token'], refresh_token: response_body['refresh_token'], expires_at: Time.zone.now + response_body['expires_in'])
  end
end
