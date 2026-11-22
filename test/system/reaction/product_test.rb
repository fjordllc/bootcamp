# frozen_string_literal: true

require 'application_system_test_case'

class Reaction::ProductsTest < ApplicationSystemTestCase
  # 取り消しなど、リアクションの操作の場合分けは test/system/reactions/report_test.rb で確かめる。
  # ここでは、この対象でリアクションの部品が働くことだけを確かめる。
  test 'reaction to product' do
    visit_with_auth product_path(products(:product12)), 'machida'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='eyes']").click

    using_wait_time 5 do
      assert_text '🎉1👀2'
    end
  end
end
