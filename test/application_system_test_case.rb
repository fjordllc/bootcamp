require "test_helper"
require "helpers/login_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper

  caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    "chromeOptions" => { "args" => %w(--headless) }
  )

  if ENV["HEADED"]
    driven_by :selenium, using: :chrome
  else
    driven_by :selenium, using: :chrome, options: { desired_capabilities: caps }
  end
end
