# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe '#initialize_github_credential' do
    let(:admin) { FactoryBot.create(:admin) }
    let(:code) { 'example_code' }

    before do
      allow(ENV).to receive(:fetch).with('GITHUB_APP_CLIENT_ID', nil).and_return('example_github_app_client_id')
      allow(ENV).to receive(:fetch).with('GITHUB_APP_CLIENT_SECRET', nil).and_return('example_github_app_client_secret')
    end

    it 'creates github_credential' do
      # アクセストークンの生成リクエストを送らないようにスタブ
      params = {
        'client_id' => ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
        'code' => code
      }
      response_body = '{"access_token":"access_token","expires_in":28800,"refresh_token":"refresh_token"}'
      stub_request(:post, 'https://github.com/login/oauth/access_token').with(body: params, headers: { Accept: 'application/json' })
                                                                        .to_return(status: 200, body: response_body)

      # トークンの有効期限の時間を固定したいので、時間を固定
      travel_to Time.zone.local(2025, 3, 1, 12) do
        expect { admin.initialize_github_credential(code) }.to change(GithubCredential, :count).by(1)
        expect(admin.github_credential.access_token).to eq 'access_token'
        expect(admin.github_credential.refresh_token).to eq 'refresh_token'
        expect(admin.github_credential.expires_at).to eq Time.zone.local(2025, 3, 1, 20)
      end
    end

    it 'raise error when request fails' do
      response_body = '<html><body><h1>Request Timeout 408</h1></body></html>'
      stub_request(:post, 'https://github.com/login/oauth/access_token').to_return(status: [408, 'Request Timeout'], body: response_body)
      expect { admin.initialize_github_credential(code) }.to raise_error("Error!, Status Code: 408 Request Timeout, Response Body: #{response_body}")
    end

    it 'raise error when response contains errors' do
      params = {
        'client_id' => ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
        'code' => code
      }
      response_body = '{"error":"incorrect_client_credentials","error_description":"The client_id and/or client_secret passed are incorrect."}'
      stub_request(:post, 'https://github.com/login/oauth/access_token').with(body: params, headers: { Accept: 'application/json' })
                                                                        .to_return(status: 200, body: response_body)
      expect { admin.initialize_github_credential(code) }.to raise_error('Error!, incorrect_client_credentials : The client_id and/or client_secret passed are incorrect.')
    end
  end
end
