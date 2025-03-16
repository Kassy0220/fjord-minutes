# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :chrome
    options = Selenium::WebDriver::Chrome::Options.new(args: ['user-data-dir=/tmp/temp_profile'])
    options.browser_version = '132.0.6834.159'
    options.binary = '/opt/hostedtoolcache/setup-chrome/chromium/132.0.6834.159/x64/chrome'
  end
end
