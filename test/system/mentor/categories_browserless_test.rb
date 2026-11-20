# frozen_string_literal: true

require 'browserless_system_test_case'

class Mentor::CategoriesBrowserlessTest < BrowserlessSystemTestCase
  test 'show listing categories' do
    visit_with_auth '/mentor/categories', 'mentormentaro'
    assert_equal 'メンターページ | FBC', title
  end

  test 'should display practice count correctly' do
    category_name = '学習の準備'
    category = Category.find_by(name: category_name)
    practice_count = category.practices.length

    visit_with_auth '/mentor/categories', 'komagata'
    assert_text "#{category_name}(#{practice_count})"
  end
end
