# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/practices/#{practices(:practice1).id}/reports", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールする | FBC', title
  end
end
