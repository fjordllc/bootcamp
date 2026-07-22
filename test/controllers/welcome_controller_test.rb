# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test 'GMO Pepabo logo is displayed first on job support page' do
    get job_support_path

    document = Nokogiri::HTML(response.body)
    first_logo = document.at_css('.lp-company-logos__item img')
    assert_equal 'GMOペパボ株式会社', first_logo['alt']
  end
end
