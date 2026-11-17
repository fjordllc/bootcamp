# frozen_string_literal: true

require 'application_system_test_case'

class BrowserlessSystemTestCase < ApplicationSystemTestCase
  driven_by :rack_test
end
