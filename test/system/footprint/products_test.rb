# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::ProductsTest < ApplicationSystemTestCase
  test 'should be create footprint in product page' do
    product = users(:mentormentaro).products.first
    visit_with_auth product_path(product), 'komagata'
    assert_text '見たよ'
    assert page.has_css?('.a-user-icon.is-komagata')
  end

  test 'should not footpoint with my own product' do
    product = users(:mentormentaro).products.first
    visit_with_auth product_path(product), 'mentormentaro'
    assert_no_text '見たよ'
    assert_not page.has_css?('.a-user-icon.is-mentormentaro')
  end

  test 'show link if there are more than ten footprints' do
    product = users(:komagata).products.first
    visit_with_auth "/products/#{products(:product3).id}", 'hatsuno'
    visit_with_auth "/products/#{products(:product3).id}", 'kimura'
    visit_with_auth "/products/#{products(:product3).id}", 'machida'
    visit_with_auth "/products/#{products(:product3).id}", 'osnashi'
    visit_with_auth "/products/#{products(:product3).id}", 'marumarushain2'
    visit_with_auth "/products/#{products(:product3).id}", 'kananasi'
    visit_with_auth "/products/#{products(:product3).id}", 'nippounashi'
    visit_with_auth "/products/#{products(:product3).id}", 'hatsuno'
    visit_with_auth "/products/#{products(:product3).id}", 'jobseeker'
    visit_with_auth "/products/#{products(:product3).id}", 'advijirou'
    visit_with_auth "/products/#{products(:product3).id}", 'hajime'
    visit_with_auth "/products/#{products(:product3).id}", 'muryou'
    assert page.has_css?('.page-content-prev-next__item-link')
  end

  test 'has no link if there are less than ten footprints' do
    product = users(:komagata).products.first
    visit_with_auth "/products/#{products(:product3).id}", 'kimura'
    visit_with_auth "/products/#{products(:product3).id}", 'machida'
    visit_with_auth "/products/#{products(:product3).id}", 'osnashi'
    visit_with_auth "/products/#{products(:product3).id}", 'marumarushain2'
    visit_with_auth "/products/#{products(:product3).id}", 'kananasi'
    visit_with_auth "/products/#{products(:product3).id}", 'nippounashi'
    visit_with_auth "/products/#{products(:product3).id}", 'hatsuno'
    visit_with_auth "/products/#{products(:product3).id}", 'jobseeker'
    visit_with_auth "/products/#{products(:product3).id}", 'advijirou'
    visit_with_auth "/products/#{products(:product3).id}", 'hajime'
    visit_with_auth "/products/#{products(:product3).id}", 'muryou'
    assert_not page.has_css?('.a-user-icon.is-komagata')
  end
end
