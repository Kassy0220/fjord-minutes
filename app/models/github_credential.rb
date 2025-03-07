# frozen_string_literal: true

class GithubCredential < ApplicationRecord
  belongs_to :admin

  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true

  def expired?
    expires_at < Time.zone.now
  end

  def update_access_token
    params = {
      client_id: ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
      client_secret: ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
      grant_type: 'refresh_token',
      refresh_token:
    }
    response = Net::HTTP.post(
      URI('https://github.com/login/oauth/access_token'),
      URI.encode_www_form(params),
      { Accept: 'application/json' }
    )
    raise "Error!, Status Code: #{response.code} #{response.message}, Response Body: #{response.body}" if response.code != '200'

    response_body = JSON.parse(response.body)
    raise "Error!, #{response_body['error']} : #{response_body['error_description']}" if response_body.key?('error')

    update!(access_token: response_body['access_token'], refresh_token: response_body['refresh_token'], expires_at: Time.zone.now + response_body['expires_in'])
  end
end
