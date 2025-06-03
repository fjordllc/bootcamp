# frozen_string_literal: true

require 'application_system_test_case'

class ProductAccessControlTest < ApplicationSystemTestCase
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

  test 'can not see tweet button when current_user does not complete a practice' do
    visit_with_auth "/products/#{products(:product1).id}", 'yamada'
    assert_no_text 'Xに修了ポストする'
  end

  test 'can see tweet button when current_user has completed a practice' do
    visit_with_auth "/products/#{products(:product2).id}", 'kimura'
    assert_text 'Xに修了ポストする'

    find('.a-button.is-tweet').click
    assert_text '喜びをXにポストする！'
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
