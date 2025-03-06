# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :authenticate_admin!

  def create
    response = request_token(params['code'])
    raise "Error!, #{response['error']} : #{response['error_description']}" if response.key?('error')

    current_admin.create_github_credential!(access_token: response['access_token'], refresh_token: response['refresh_token'], expires_at: Time.zone.now + response['expires_in'])

    minute = Minute.find(params['state'])
    MinuteGithubExporter.export_to_github_wiki(minute, current_admin.github_credential.access_token)
    minute.update!(exported: true) unless minute.exported?
    redirect_to course_minutes_path(minute.course), notice: t('.success')
  end

  private

  def request_token(code)
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

    JSON.parse(response.body)
  end
end
