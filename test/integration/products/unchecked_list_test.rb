# frozen_string_literal: true

require 'test_helper'
require 'supports/product_helper'

class Products::UncheckedListTest < ActionDispatch::IntegrationTest
  include ProductHelper

  test 'non-staff user cannot see unchecked products' do
    login 'hatsuno'
    get '/products/unchecked'
    assert_redirected_to root_path
    assert_equal '管理者・アドバイザー・メンターとしてログインしてください', flash[:alert]
  end

  test 'adviser does not see the unchecked tab' do
    login 'advijirou'
    get '/products'
    assert_response :success
    assert_select '.page-tabs__item-link', text: /未完了/, count: 0
  end

  test 'admin sees the unchecked tab with the number of products excluding hibernated users' do
    login 'komagata'
    get '/products/unchecked'
    assert_response :success
    assert_select 'title', text: /未完了の提出物/
    expected_count = Product.unhibernated_user_products.unchecked.not_wip.count
    assert_select '.page-tabs__item-link.is-active', text: "未完了 （#{expected_count}）"
    assert_select 'button', text: '未完了の提出物を一括で開く'
  end

  test 'product page has a link to the unchecked list' do
    login 'komagata'
    get "/products/#{products(:product1).id}"
    assert_select 'a', text: '未完了一覧'
  end

  test 'unchecked products are listed from the oldest' do
    delete_most_unchecked_products!
    expected_ids = Product.unhibernated_user_products.unchecked.not_wip.ascending_by_date_of_publishing_and_id.pluck(:id)

    login 'komagata'
    get '/products/unchecked'
    assert_equal expected_ids, listed_product_ids
  end

  test 'checked product is not listed' do
    product = create_assigned_product(users(:mentormentaro))
    Check.create!(user: users(:komagata), checkable: product)

    login 'komagata'
    get '/products/unchecked?target=unchecked_all'
    assert_response :success
    assert_not_includes Product.unchecked, product
    assert_select product_link(product), false
  end

  test 'no-replied list shows products without comments' do
    product = products(:product8)

    assert_includes no_replied_product_ids, product.id
  end

  test 'no-replied list shows products last commented by the submitter' do
    product = products(:product8)
    Comment.create!(user: product.user, commentable: product, description: 'test')

    assert_includes no_replied_product_ids, product.id
  end

  test 'no-replied list hides products last commented by a mentor' do
    product = products(:product8)
    Comment.create!(user: users(:mentormentaro), commentable: product, description: 'test')

    assert_not_includes no_replied_product_ids, product.id
  end

  test 'self-assigned list shows the product commented by the submitter' do
    product = create_assigned_product(users(:kimura))
    Comment.create!(user: users(:kimura), commentable: product, description: 'test')

    login 'komagata'
    get '/products/self_assigned'
    assert_select product_link(product)
  end

  test 'no-replied list can be narrowed down by the assigned mentor' do
    product = create_assigned_product(users(:kimura))

    login 'mentormentaro'
    get "/products/unchecked?checker_id=#{product.checker_id}&target=unchecked_no_replied"
    assert_select product_link(product)
    assert_select '.card-list-item__assignee[data-checker-name="komagata"]'
    assert_select '.card-list-item__assignee:not([data-checker-name="komagata"])', false
  end

  private

  def login(login_name)
    post user_sessions_path, params: { user: { login: login_name, password: 'testtest' } }
  end

  def create_assigned_product(user)
    Product.create!(body: 'test', user:, practice: practices(:practice47), checker_id: users(:komagata).id)
  end

  def product_link(product)
    %(.card-list-item a[href$="/products/#{product.id}"])
  end

  def listed_product_ids
    css_select('.card-list-item-title__link, .card-list-item a[href*="/products/"]').filter_map { |a| a['href'][%r{/products/(\d+)\z}, 1]&.to_i }.uniq
  end

  # 未返信の一覧に出る提出物を、ページをまたいで集める
  def no_replied_product_ids
    login 'komagata'
    ids = []
    (1..10).each do |page|
      get "/products/unchecked?target=unchecked_no_replied&page=#{page}"
      assert_response :success
      found = listed_product_ids
      break if found.empty?

      ids.concat(found)
    end
    ids
  end
end
