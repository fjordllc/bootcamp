# frozen_string_literal: true

require 'application_system_test_case'

class ProductWipTest < ApplicationSystemTestCase
  test 'should change learning status when change wip status' do
    product = products(:product5)
    product_path = "/products/#{product.id}"
    practice_path = "/practices/#{product.practice.id}"

    visit_with_auth "#{product_path}/edit", 'kimura'
    click_button '提出する'
    visit practice_path

    assert find_button(class: 'is-submitted', disabled: true).matches_css?('.is-active')

    products(:product8).change_learning_status(:started)
    visit "#{product_path}/edit"
    click_button 'WIP'
    visit practice_path

    assert find_button(class: 'is-unstarted', disabled: true).matches_css?('.is-active')

    products(:product8).change_learning_status(:submitted)
    visit product_path
    click_button '提出する'
    visit "#{product_path}/edit"
    click_button 'WIP'
    visit practice_path

    assert find_button(class: 'is-started', disabled: true).matches_css?('.is-active')
  end

  test 'should unchange learning status when change wip status' do
    product = products(:product8)
    product_path = "/products/#{product.id}"
    practice_path = "/practices/#{product.practice.id}"

    visit_with_auth "#{product_path}/edit", 'kimura'
    product.change_learning_status(:started)
    visit "#{product_path}/edit"
    click_button 'WIP'
    visit practice_path

    assert find_button(class: 'is-started', disabled: true).matches_css?('.is-active')
  end

  test 'create product as WIP' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'
    assert_text '提出物編集'
  end

  test 'update product as WIP' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button 'WIP'
    assert_text '提出物をWIPとして保存しました。'
    assert_text '提出物編集'
  end

  test 'update product as WIP with blank body to fail update and successfully get back to editor' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: '')
    end
    click_button 'WIP'
    assert_text '本文を入力してください'
  end

  test 'user who has submitted a WIP product is alerted in the product page' do
    wip_product = products(:product5)
    visit_with_auth "/products/#{wip_product.id}", 'kimura'
    assert_text "提出物はまだ提出されていません。\n完成したら「提出する」をクリック！"
  end

  test "user is not alerted in the other's WIP product page" do
    wip_product = products(:product5)
    visit_with_auth "/products/#{wip_product.id}", 'hatsuno'
    assert_equal "提出物: #{wip_product.practice.title} | FBC", title
    assert_no_text "提出物はまだ提出されていません。\n完成したら「提出する」をクリック！"
  end

  test 'update published_at when update product content after wips submitted product' do
    product = products(:product5)
    product_published_at = product.published_at

    visit_with_auth "/products/#{product.id}", 'kimura'
    click_button '提出する'

    assert product.reload.published_at > product_published_at
  end

  test 'not update published_at when update product content after submitted product' do
    product = products(:product12)
    product_published_at = product.published_at

    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    click_button '提出する'

    assert product.reload.published_at = product_published_at
  end

  test 'submit-wip-submitted product does not suddenly show up as overdue' do
    visit_with_auth "/products/#{products(:product8).id}/edit", 'kimura'
    click_button 'WIP'
    click_button '提出する'

    visit_with_auth '/api/products/unassigned/counts.txt', 'komagata'

    expected = <<~BODY
      - 6日以上経過：6件
      - 5日経過：1件
      - 4日経過：1件
    BODY
    assert_includes page.body, expected
  end
end
