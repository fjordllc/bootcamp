# frozen_string_literal: true

require 'application_system_test_case'

class API::GrassesTest < ApplicationSystemTestCase
  test 'get grass' do
    visit_with_auth "/api/grasses/#{users(:sotugyou).id}.json", 'kimura'
    assert_text 'velocity'
  end

  test 'get grass with date' do
    visit_with_auth "/api/grasses/#{users(:sotugyou).id}.json?end_date=2021-10-01", 'kimura'
    assert_text 'velocity'
  end
end
