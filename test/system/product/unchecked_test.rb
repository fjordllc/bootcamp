# frozen_string_literal: true

require 'application_system_test_case'

class Product::UncheckedTest < ApplicationSystemTestCase
  # 一覧に出る条件、並び順、役割ごとの見え方は
  # test/integration/products/unchecked_list_test.rb で確かめる。
  test 'display products last commented by submitter if click on no-replied-button' do
    product = products(:product8)
    visit_with_auth "/products/#{product.id}", 'kimura'
    fill_in('comment[description]', with: 'test')
    click_button 'コメントする'
    within('.thread-comments__items > .thread-comment:last-child') do
      assert_text 'kimura'
      assert_text 'test'
    end
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    assert_text product.practice.title
    assert_selector '.card-list-item-meta__item', text: '提出者'
  end

  test "show only mentor's products if you select a mentor in products unchecked all" do
    user = users(:kimura)
    practice = practices(:practice47)
    checker = users(:komagata)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )

    visit_with_auth '/products/unchecked', 'mentormentaro'
    find('.choices__inner').click
    find('.choices__item--choice', text: 'komagata').click
    find('.pill-nav__item-link', text: '全て').click
    assert_current_path("/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_all")
    assert_selector '.card-list-item__assignee-name', text: 'komagata'
    assert_no_selector '.card-list-item__assignee-name', text: 'machida'
  end
end
