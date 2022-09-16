# frozen_string_literal: true

require 'application_system_test_case'

class Practice::ReportsTest < ApplicationSystemTestCase
  test 'show listing reports' do
    visit_with_auth "/practices/#{practices(:practice1).id}/reports", 'hatsuno'
    assert_equal 'OS X Mountain Lionをクリーンインストールするに関する日報 | FBC', title
    assert_selector 'img[alt="happy"]', count: 2
    assert_selector '.card-list-item-title__link', text: '1時間だけ学習'
  end
end
