# frozen_string_literal: true

require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test 'all_countries_with_subdivisions' do
    countries = JSON.parse(all_countries_with_subdivisions)
    assert_includes countries['JP'], %w[北海道 01]
    assert_includes countries['US'], %w[アラスカ州 AK]
  end
end
