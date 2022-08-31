# frozen_string_literal: true

require 'application_system_test_case'

class Product::CheckerTest < ApplicationSystemTestCase
  test 'be person on charge at comment on product of there are not person on charge' do
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'machida'
    def assigned_product_count
      text[/自分の担当 （(\d+)）/, 1].to_i
    end

    before_comment = assigned_product_count

    visit "/products/#{products(:product1).id}"

    post_comment('担当者がいない提出物の場合、担当者になる')
    assert_text '担当になりました。'
    assert_text '担当から外れる'

    post_comment('自分が担当者の場合、担当者のまま')
    assert_text 'コメントを投稿しました！'
    assert_text '担当から外れる'

    visit '/products/unchecked?target=unchecked_no_replied'
    assert_equal before_comment + 1, assigned_product_count
  end

  test 'be not person on charge at comment on product of there are person on charge' do
    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'komagata'
    product = find('.card-list-item', match: :first)
    product.click_button '担当する'
    assert_text '担当から外れる'

    show_product_path = product.find_link(href: /products/)[:href]
    logout

    visit_with_auth '/products/unchecked?target=unchecked_no_replied', 'machida'

    def assigned_product_count
      text[/自分の担当 （(\d+)）/, 1].to_i
    end

    before_comment = assigned_product_count

    visit show_product_path
    post_comment('担当者がいる提出物の場合、担当者にならない')
    assert_text 'コメントを投稿しました！'

    visit '/products/unchecked?target=unchecked_no_replied'
    assert_equal before_comment, assigned_product_count
  end

  test 'when student comment to a product, they are not in charge' do
    old_product = products(:product8)

    visit_with_auth product_url(old_product), 'kimura'

    within first('#comments.loaded', wait: 10) do
      fill_in 'new_comment[description]', with: 'edit test'
      click_button 'コメントする'
    end

    assert_text 'コメントを投稿しました'
    assert_nil Product.find(old_product.id).checker_id
  end
end
