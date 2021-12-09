# frozen_string_literal: true

require 'application_system_test_case'

class User::ProductsTest < ApplicationSystemTestCase
  test 'show listing products' do
    visit_with_auth "/users/#{users(:hatsuno).id}/products", 'komagata'
    assert_equal 'hatsunoの提出物 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'products order' do
    user = users(:with_hyphen)

    # id順で並べたときの最初と最後の提出物を、作成日順で見たときに最新と最古になるように入れ替える
    Product.where(user: user).update_all(created_at: 1.day.ago, published_at: 1.day.ago) # rubocop:disable Rails/SkipsModelValidations
    newest_product = Product.where(user: user).first
    newest_product.update(created_at: Time.current)
    oldest_product = Product.where(user: user).last
    oldest_product.update(created_at: 2.days.ago)

    visit_with_auth "/users/#{user.id}/products", 'komagata'

    # 作成日の降順で並んでいることを検証する
    titles = all('.thread-list-item-title__title').map { |t| t.text.gsub('★', '') }
    names = all('.thread-list-item-meta .a-user-name').map(&:text)
    assert_equal "#{newest_product.practice.title}の提出物", titles.first
    assert_equal newest_product.user.login_name, names.first
    assert_equal "#{oldest_product.practice.title}の提出物", titles.last
    assert_equal oldest_product.user.login_name, names.last
  end
end
