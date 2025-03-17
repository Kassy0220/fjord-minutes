# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
    driven_by :selenium, using: :headless_firefox
  end
end
