# frozen_string_literal: true

require 'application_system_test_case'

module Products
  class PermissionTest < ApplicationSystemTestCase
    test 'see my product' do
      visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
      assert_equal "提出物: #{products(:product1).practice.title} | FBC", title
    end

    test 'admin can see a product' do
      visit_with_auth "/products/#{products(:product1).id}", 'komagata'
      assert_equal "提出物: #{products(:product1).practice.title} | FBC", title
    end

    test 'adviser can see a product' do
      visit_with_auth "/products/#{products(:product1).id}", 'advijirou'
      assert_equal "提出物: #{products(:product1).practice.title} | FBC", title
    end

    test 'graduate can see a product' do
      visit_with_auth "/products/#{products(:product1).id}", 'sotugyou'
      assert_equal "提出物: #{products(:product1).practice.title} | FBC", title
    end

    test "user who completed the practice can see the other user's product" do
      visit_with_auth "/products/#{products(:product1).id}", 'kimura'
      assert_equal "提出物: #{products(:product1).practice.title} | FBC", title
    end

    test "can see other user's product if it is permitted" do
      visit_with_auth "/products/#{products(:product3).id}", 'hatsuno'
      assert_equal "提出物: #{products(:product3).practice.title} | FBC", title
    end

    test "can not see other user's product if it isn't permitted" do
      visit_with_auth "/products/#{products(:product1).id}", 'hatsuno'
      assert_not_equal '提出物 | FBC', title
      assert_text 'プラクティスを修了するまで他の人の提出物は見れません。'
    end

    test 'admin can delete a product' do
      product = products(:product1)
      visit_with_auth "/products/#{product.id}", 'komagata'
      accept_confirm do
        click_link '削除'
      end
      assert_text '提出物を削除しました。'
    end

    test 'notice accessibility to open products on products index' do
      visit_with_auth "/users/#{users(:kimura).id}/products/", 'kimura'
      assert_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
    end

    test 'notice accessibility to itself on an open product page' do
      visit_with_auth "/products/#{products(:product2).id}", 'kimura'
      assert_no_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
      visit "/products/#{products(:product3).id}"
      assert_text 'このプラクティスは、OKをもらっていなくても他の人の提出物を閲覧できます。'
    end
  end
end
