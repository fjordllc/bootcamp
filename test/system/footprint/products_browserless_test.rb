# frozen_string_literal: true

require 'browserless_system_test_case'

class Footprint::ProductsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @product = products(:product3)
  end

  test 'should be create footprint in product page' do
    visit_with_auth product_path(@product), 'komagata'
    assert_css '.a-user-icon.is-komagata'
  end

  test 'show link if there are more than ten footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @product.id,
        footprintable_type: 'Product'
      )
    end

    visit_with_auth product_path(@product), 'komagata'
    assert_css '.user-icons__more'
  end

  test 'has no link if there are less than ten footprints' do
    user_data = User.unhibernated.unretired.last(9)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @product.id,
        footprintable_type: 'Product'
      )
    end

    visit_with_auth product_path(@product), 'komagata'
    assert_no_css '.user-icons__more'
  end
end
