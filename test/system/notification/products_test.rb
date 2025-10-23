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
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    notifications = Notification.where(user: users(:senpai), kind: Notification.kinds[:submitted])
    assert notifications.any? { |n| n.message.include?("kensyuさんが「#{practices(:practice5).title}」の提出物を提出しました。") }
  end

  test 'update product notification message for checker' do
    product = products(:product2)

    visit_with_auth "/products/#{product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出物を更新しました。'

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:product_update])
    assert notifications.any? { |n| n.message.include?("kimuraさんの「#{product.practice.title}」の提出物が更新されました。") }
  end

  test 'update product notification message for watcher' do
    # 担当者がいなくてwatchされていない提出物
    product = products(:product73)

    visit_with_auth "/products/#{product.id}/", 'komagata'

    find('.watch-toggle').click
    assert_text 'Watchしました！'

    visit_with_auth "/products/#{product.id}/edit", 'hajime'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出物を更新しました。'

    notifications = Notification.where(user: users(:komagata), kind: Notification.kinds[:product_update])
    assert notifications.any? { |n| n.message.include?("hajimeさんの「#{product.practice.title}」の提出物が更新されました。") }
  end

  test 'checked product notification message' do
    checker = users(:komagata)
    practice = practices(:practice47)
    user = users(:kimura)
    product = Product.create!(
      body: 'test',
      user:,
      practice:,
      checker_id: checker.id
    )
    visit_with_auth "/products/#{product.id}", 'komagata'
    click_button '提出物を合格にする'
    assert_text '提出物を合格にしました。'

    notifications = Notification.where(user: users(:kimura), kind: Notification.kinds[:checked])
    assert notifications.any? { |n| n.message.include?("#{checker.login_name}さんが「#{practices(:practice47).title}」の提出物を確認しました。") }
  end

  test 'send the notification of practices mentor is watching' do
    practice = practices(:practice5)

    visit_with_auth "/practices/#{practice.id}", 'mentormentaro'
    find('div.a-watch-button', text: 'Watch').click

    assert_text 'Watch中'

    visit_with_auth "/products/new?practice_id=#{practice.id}", 'hatsuno'
    fill_in 'product[body]', with: 'test'
    click_button '提出する'

    notifications = Notification.where(user: users(:mentormentaro), kind: Notification.kinds[:watching])
    assert notifications.any? { |n| n.message.include?("#{users(:hatsuno).login_name}さんが「#{practice.title}」の提出物を提出しました。") }
  end
end
