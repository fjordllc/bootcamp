# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/practices/#{practices(:practice1).id}/reports", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する日報 | FBC', title
    within first('.card-list-item') do
      assert_selector 'img[alt="happy"]'
      assert_text '1時間だけ学習'
    end
  end
end
