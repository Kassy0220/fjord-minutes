# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless do |options|
      options.browser_version = '132.0.6834.159'
    end
  end
end
