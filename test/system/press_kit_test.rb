# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show listing press kit' do
    visit press_kit_url
    expected_title = 'プレスキット | FJORD BOOT CAMP（フィヨルドブートキャンプ）'
    assert_includes title, expected_title
  end
end
