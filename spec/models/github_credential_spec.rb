# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubCredential, type: :model do
  describe '#expired?' do
    let(:github_credential) { FactoryBot.build(:github_credential, expires_at: Time.zone.local(2025, 2, 1, 12), admin: FactoryBot.create(:admin)) }

    it 'returns true if access_token has expired' do
      travel_to Time.zone.local(2025, 2, 1, 13) do
        expect(github_credential.expired?).to be true
      end
    end

    it 'reuturns false if access_token has not expired' do
      travel_to Time.zone.local(2025, 2, 1, 11) do
        expect(github_credential.expired?).to be false
      end
    end
  end

  describe '#update_access_token' do
    let(:github_credential) { FactoryBot.create(:github_credential, admin: FactoryBot.create(:admin)) }

    before do
      allow(ENV).to receive(:fetch).with('GITHUB_APP_CLIENT_ID', nil).and_return('example_github_app_client_id')
      allow(ENV).to receive(:fetch).with('GITHUB_APP_CLIENT_SECRET', nil).and_return('example_github_app_client_secret')
    end

    it 'update access_token, refresh_token and expires_at' do
      # アクセストークンの更新リクエストを送らないようにスタブ
      params = {
        'client_id' => ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
        'grant_type' => 'refresh_token',
        'refresh_token' => 'ghijkl'
      }
      response_body = '{"access_token":"updated_access_token","expires_in":28800,"refresh_token":"updated_refresh_token"}'
      stub_request(:post, 'https://github.com/login/oauth/access_token').with(body: params, headers: { Accept: 'application/json' })
                                                                        .to_return(status: 200, body: response_body)

      # トークンの有効期限の時間を固定したいので、時間を固定
      travel_to Time.zone.local(2025, 3, 1, 12) do
        expect { github_credential.update_access_token }.to change(github_credential, :access_token).from('abcdef').to('updated_access_token')
                                                        .and change(github_credential, :refresh_token).from('ghijkl').to('updated_refresh_token')
                                                        .and change(github_credential, :expires_at).from(github_credential.expires_at).to(Time.zone.local(2025, 3, 1, 20))
      end
    end

    it 'raise error when request fails' do
      response_body = '<html><body><h1>Request Timeout 408</h1></body></html>'
      stub_request(:post, 'https://github.com/login/oauth/access_token').to_return(status: [408, 'Request Timeout'], body: response_body)
      expect { github_credential.update_access_token }.to raise_error("Error!, Status Code: 408 Request Timeout, Response Body: #{response_body}")
    end

    it 'raise error when response contains errors' do
      params = {
        'client_id' => ENV.fetch('GITHUB_APP_CLIENT_ID', nil),
        'client_secret' => ENV.fetch('GITHUB_APP_CLIENT_SECRET', nil),
        'grant_type' => 'refresh_token',
        'refresh_token' => 'ghijkl'
      }
      response_body = '{"error":"incorrect_client_credentials","error_description":"The client_id and/or client_secret passed are incorrect."}'
      stub_request(:post, 'https://github.com/login/oauth/access_token').with(body: params, headers: { Accept: 'application/json' })
                                                                        .to_return(status: 200, body: response_body)
      expect { github_credential.update_access_token }.to raise_error('Error!, incorrect_client_credentials : The client_id and/or client_secret passed are incorrect.')
    end
  end
end
