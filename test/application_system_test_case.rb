# frozen_string_literal: true

require "test_helper"
require "supports/login_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper

  chrome_bin = ENV.fetch("GOOGLE_CHROME_SHIM", nil)
  chrome_opts = { chromeOptions: { args: %w(--headless) } }
  chrome_opts[:chromeOptions][:binary] = chrome_bin if chrome_bin
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(chrome_opts)

  if ENV["HEADED"]
    driven_by :selenium, using: :headless_chrome
  else
    driven_by :selenium, using: :headless_chrome, options: { desired_capabilities: caps }
  end

  setup do
    Bootcamp::Setup.attachment
  end
end
