# frozen_string_literal: true

require 'application_system_test_case'

class ProductCrudTest < ApplicationSystemTestCase
  test 'create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    assert_text 'Watch中'
  end

  test 'should change messages when submit product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'hatsuno'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit "/practices/#{practices(:practice6).id}"
    assert_equal first('.test-product').text, '提出物へ'
  end

  test 'update product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text '提出物を更新しました。'
  end

  test 'update product to publish from WIP' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}/edit", 'mentormentaro'
    click_button 'WIP'
    visit "/products/#{product.id}"
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text '提出物を更新しました。'
  end

  test 'update product after checked' do
    my_product = products(:product2)
    others_product = products(:product15)
    visit_with_auth "/products/#{my_product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'

    visit "/products/#{others_product.id}"
    assert_current_path("/products/#{others_product.id}")
  end

  test 'delete product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'mentormentaro'
    accept_confirm do
      click_link '削除'
    end
    assert_text '提出物を削除しました。'
  end

  test 'admin can delete a product' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'komagata'
    accept_confirm do
      click_link '削除'
    end
    assert_text '提出物を削除しました。'
  end

  test 'product has a comment form ' do
    visit_with_auth "/products/#{products(:product1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
  end

  test 'show user name_kana next to name' do
    product = products(:product1)
    visit_with_auth "/products/#{product.id}", 'kimura'
    user = product.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    assert_text decorated_user.long_name
  end

  test 'show number of comments' do
    visit_with_auth "/products/#{products(:product1).id}", 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'no company trainee create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'nocompanykensyu'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text Time.zone.now.strftime('%Y年%m月%d日')
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    assert_text 'Watch中'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice6).id}", 'mentormentaro'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'return practice page when click cancel on new product page' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice1).id}", 'hatsuno'
    click_link 'キャンセル'
    assert_selector '.page-tabs__item-link.is-active', text: 'プラクティス'
    assert_link '提出物を作る'
  end

  test 'return wip product page when click cancel on edit product page' do
    visit_with_auth "/products/#{products(:product5).id}/edit", 'kimura'
    click_link 'キャンセル'
    assert_selector '.page-tabs__item-link.is-active', text: '提出物'
    assert_link '内容修正'
  end
end
