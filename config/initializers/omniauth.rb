Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer, fields: [ :email, :nickname, :image ], uid_field: :email if Rails.env.development?
  provider :github, ENV["AUTH_APP_ID"], ENV["AUTH_APP_SECRET"]
  on_failure { |env| OmniAuth::FailureEndpoint.new(env).redirect_to_failure }
end
