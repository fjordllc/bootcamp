# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class OrderTest < ApplicationSystemTestCase
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
      titles = all('.card-list-item-title__title').map { |t| t.text.delete('★') }
      names = all('.card-list-item-meta .a-user-name').map(&:text)
      assert_equal "#{newest_product.practice.title}の提出物", titles.first
      assert_equal newest_product_decorated_author.long_name, names.first
      assert_equal "#{oldest_product.practice.title}の提出物", titles.last
      assert_equal oldest_product_decorated_author.long_name, names.last
    end
  end
end
