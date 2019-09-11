# frozen_string_literal: true

require "test_helper"
require "supports/login_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include LoginHelper

  if ENV["HEADED"]
    driven_by :selenium, using: :chrome
  else
    driven_by :selenium, using: :headless_chrome
  end

  setup do
    Bootcamp::Setup.attachment
  end
end
