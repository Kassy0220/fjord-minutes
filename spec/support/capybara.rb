# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    options = Selenium::WebDriver::Chrome::Options.new
    options.browser_version = '132.0.6834.159'
    options.binary = '/opt/hostedtoolcache/setup-chrome/chromium/132.0.6834.159/x64/chrome'

    driven_by :selenium, using: :chrome, options: { browser: :chrome, options: options }
  end
end
