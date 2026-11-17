# frozen_string_literal: true

require 'browserless_system_test_case'

module Products
  class TraineeBrowserlessTest < BrowserlessSystemTestCase
    test 'display company-logo when user is trainee' do
      visit_with_auth "/products/#{products(:product13).id}", 'mentormentaro'
      assert_selector 'img[class="page-content-header__company-logo-image"]'
    end

    test 'display training end date in products for mentor only' do
      Product.where.not(user: users(:kensyu)).delete_all

      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth '/products', 'mentormentaro'
        find('.is-products.loaded')
        assert_selector '.a-meta__label', text: '研修終了予定日'
        assert_selector '.a-meta__value', text: '2022年04月01日'
        assert_selector '.a-meta__value', text: '（あと365日）'
      end
    end

    test 'display training end date in product show for mentor only' do
      Product.where.not(user: users(:kensyu)).delete_all

      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth "/products/#{products(:product13).id}", 'mentormentaro'
        find('.page-content-header__before-title')
        assert_selector '.a-meta__label', text: '研修終了予定日'
        assert_selector '.a-meta__value', text: '2022年04月01日'
        assert_selector '.a-meta__value', text: '（あと365日）'
      end
    end

    test 'display training end date in products for admin only' do
      Product.where.not(user: users(:kensyu)).delete_all

      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth '/products', 'adminonly'
        find('.is-products.loaded')
        assert_selector '.a-meta__label', text: '研修終了予定日'
        assert_selector '.a-meta__value', text: '2022年04月01日'
        assert_selector '.a-meta__value', text: '（あと365日）'
      end
    end

    test 'display training end date in product show for admin only' do
      Product.where.not(user: users(:kensyu)).delete_all

      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth "/products/#{products(:product13).id}", 'adminonly'
        find('.page-content-header__before-title')
        assert_selector '.a-meta__label', text: '研修終了予定日'
        assert_selector '.a-meta__value', text: '2022年04月01日'
        assert_selector '.a-meta__value', text: '（あと365日）'
      end
    end

    test 'display training end date in products for adviser' do
      Product.where.not(user: users(:kensyu)).delete_all

      travel_to Time.zone.local(2021, 4, 1, 0, 0, 0) do
        visit_with_auth '/products', 'advijirou'
        find('.is-products.loaded')
        assert_no_selector '.a-meta__label', text: '研修終了予定日'
        assert_no_selector '.a-meta__value', text: '2022年04月01日'
        assert_no_selector '.a-meta__value', text: '（あと365日）'
      end
    end
  end
end
