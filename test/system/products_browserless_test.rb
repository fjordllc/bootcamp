# frozen_string_literal: true

require 'browserless_system_test_case'

class ProductsBrowserlessTest < BrowserlessSystemTestCase
  test 'show user name_kana next to name' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'kimura'
    user = product.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    assert_text decorated_user.long_name
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
