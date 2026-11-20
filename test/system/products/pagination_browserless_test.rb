# frozen_string_literal: true

require 'browserless_system_test_case'

class Products::PaginationBrowserlessTest < BrowserlessSystemTestCase
  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - Product.default_per_page
    Product.where.missing(:product_ai_review).limit(count_of_delete + 1).each(&:delete) if count_of_delete.positive?

    visit_with_auth '/products', 'komagata'

    assert_not page.has_css?('.pagination')
  end
end
