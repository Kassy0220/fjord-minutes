Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["AUTH_APP_ID"], ENV["AUTH_APP_SECRET"]
end
