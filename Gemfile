# frozen_string_literal: true

source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'bootsnap', require: false
gem 'devise'
gem 'devise-i18n'
gem 'discord-notifier'
gem 'git'
gem 'holiday_jp'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'jwt'
gem 'meta-tags'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '7.2.2.1'
gem 'rails-i18n', '~> 7.0.0'
gem 'redis', '>= 4.0.1'
gem 'sprockets-rails'
gem 'stimulus-rails'
# 一旦Tailwindのバージョン3で固定するため、以下のバージョンを指定
# 将来Tailwindバージョン4にアップグレードする
gem 'tailwindcss-rails', '~> 3.3.1'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'dotenv'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'benchmark'
  gem 'bullet'
  gem 'erb_lint', require: false
  gem 'rubocop', require: false
  gem 'rubocop-fjord', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock'
end
