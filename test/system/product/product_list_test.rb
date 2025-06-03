# frozen_string_literal: true

require 'application_system_test_case'

class ProductListTest < ApplicationSystemTestCase
  test 'products order on all tab' do
    Product.update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    # 最新と最古の提出物を画面上で判定するため、提出物を1ページ内に収める
    Product.limit(Product.count - Product.default_per_page).delete_all
    newest_product = Product.reorder(:id).first
    newest_product.update(published_at: Time.current)
    newest_product_decorated_author = ActiveDecorator::Decorator.instance.decorate(newest_product.user)
    oldest_product = Product.reorder(:id).last
    oldest_product_decorated_author = ActiveDecorator::Decorator.instance.decorate(oldest_product.user)
    oldest_product.update(published_at: 2.days.ago)

    visit_with_auth '/products', 'komagata'

    # 提出日の新しい順で並んでいることを検証する
    titles = all('.card-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.card-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product_decorated_author.long_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product_decorated_author.long_name, names.last
  end

  test 'click on the pager button' do
    login_user 'komagata', 'testtest'
    visit '/products'
    within first('.pagination') do
      find('button', text: '2').click
    end

    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'specify the page number in the URL' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
    assert_current_path('/products?page=2')
  end

  test 'clicking the browser back button will show the previous page' do
    login_user 'komagata', 'testtest'
    visit '/products?page=2'
    within first('.pagination') do
      find('button', text: '1').click
    end
    assert_current_path('/products')
    assert_text '「プログラミング入門 - Rubyを使って」をやるの提出物'
    page.go_back
    assert_current_path('/products?page=2')
    all('.pagination .is-active').each do |active_button|
      assert active_button.has_text? '2'
    end
  end

  test 'When the number of pages is one, the pager will not be displayed' do
    count_of_delete = Product.count - Product.default_per_page
    if count_of_delete.positive?
      Product.all.each_with_index do |product, index|
        product.delete

        break if index >= count_of_delete
      end
    end

    visit_with_auth '/products', 'komagata'

    assert_not page.has_css?('.pagination')
  end
end
