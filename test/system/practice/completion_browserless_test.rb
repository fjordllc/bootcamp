# frozen_string_literal: true

require 'browserless_system_test_case'

class Practice::CompletionBrowserlessTest < BrowserlessSystemTestCase
  test 'not logging-in user can access show' do
    visit "/practices/#{practices(:practice1).id}/completion"
    assert_text '「OS X Mountain Lionをクリーンインストールする」'
  end
end
