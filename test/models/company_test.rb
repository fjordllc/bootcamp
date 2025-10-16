# frozen_string_literal: true

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  test '#logo_url' do
    company_with_logo = companies(:company1)
    logo_url = company_with_logo.logo_url
    assert logo_url.include?('.webp') || logo_url.include?('.jpg'), "Expected logo_url to include .webp or .jpg, but got: #{logo_url}"

    company_without_logo = companies(:company5)
    assert_equal '/images/companies/logos/default.png', company_without_logo.logo_url
  end
end
