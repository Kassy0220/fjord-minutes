Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["AUTH_APP_ID"], ENV["AUTH_APP_SECRET"]
  on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end
