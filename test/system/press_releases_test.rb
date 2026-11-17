# frozen_string_literal: true

require 'browserless_system_test_case'

class PressReleasesTest < BrowserlessSystemTestCase
  test 'show listing press releases' do
    visit press_releases_path
    assert_equal 'プレスリリース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
