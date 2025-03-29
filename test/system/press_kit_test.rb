# frozen_string_literal: true

require 'application_system_test_case'

class PressKitTest < ApplicationSystemTestCase
  test 'show listing press kit' do
    visit press_kit_url
    assert_equal 'プレスキット | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
