# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::ProductsTest < ApplicationSystemTestCase
  test 'should be create footprint in product page' do
    product = users(:mentormentaro).products.first
    visit_with_auth product_path(product), 'komagata'
    assert_text '見たよ'
    assert page.has_css?('.footprints-item__checker-icon.is-komagata')
  end

  test 'should not footpoint with my own product' do
    product = users(:mentormentaro).products.first
    visit_with_auth product_path(product), 'mentormentaro'
    assert_no_text '見たよ'
    assert_not page.has_css?('.footprints-item__checker-icon.is-mentormentaro')
  end
end
