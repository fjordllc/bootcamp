# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ProductsTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'send adviser a notification when trainee create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice5).id}", 'kensyu'

    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit_with_auth '/notifications', 'senpai'

    within first('.card-list-item.is-unread') do
      assert_text "kensyuさんが「#{practices(:practice5).title}」の提出物を提出しました。"
    end
  end

  test 'update product notification message' do
    product = products(:product2)

    visit_with_auth "/products/#{product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出物を更新しました。'

    visit_with_auth '/notifications', 'komagata'

    within first('.card-list-item.is-unread') do
      assert_text 'kimuraさんの提出物が更新されました'
    end
  end

  test 'checked product notification message' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user: user,
      practice: practice,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'komagata'
    click_button '提出物を確認'
    assert_text '提出物を確認済みにしました。'

    visit_with_auth '/notifications', 'kimura'

    within first('.card-list-item.is-unread') do
      assert_text "#{checker.login_name}さんが「#{practices(:practice47).title}」の提出物を確認しました。"
    end
  end

  test 'send the notification of practices mentor is watching' do
    practice = practices(:practice1)

    visit_with_auth "/practices/#{practice.id}", 'mentormentaro'
    find('div.a-watch-button', text: 'Watch').click

    visit_with_auth "/products/new?practice_id=#{practice.id}", 'hatsuno'
    fill_in 'product[body]', with: 'test'
    click_button '提出する'

    visit_with_auth '/notifications?status=unread&target=watching', 'mentormentaro'
    within first('.card-list-item-title__link-label') do
      assert_text "#{users(:hatsuno).login_name}さんが「#{practice.title}」の提出物を提出しました。"
    end
  end

  test 'send the notification of product is reviewing' do
    product = products(:product8)

    visit_with_auth "/products/#{product.id}", 'komagata'
    click_button '担当する'
    assert_text '担当になりました。'

    visit_with_auth '/notifications', 'kimura'

    within first('.card-list-item.is-unread') do
      assert_text 'プラクティス「PC性能の見方を知る」の提出物がレビュー中になりました（担当メンター komagata）'
    end
  end
end
