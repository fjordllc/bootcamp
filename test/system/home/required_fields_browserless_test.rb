# frozen_string_literal: true

require 'browserless_system_test_case'

module Home
  class RequiredFieldsBrowserlessTest < BrowserlessSystemTestCase
    test 'not show message of after_graduation_hope for graduated user' do
      visit_with_auth '/', 'sotugyou'
      assert_selector 'h2.page-header__title', text: 'ダッシュボード'
      assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。'
    end
  end
end
