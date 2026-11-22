# frozen_string_literal: true

require 'notification_system_test_case'

class Notification::ProductsTest < NotificationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  # 合格の通知の文面は test/models/check_callbacks_test.rb で、
  # Watch している人への通知は test/models/product_update_notifier_for_watcher_test.rb と
  # test/models/product_notifier_for_practice_watcher_test.rb で確かめる。
  test 'send adviser a notification when trainee create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice5).id}", 'kensyu'

    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end

    click_button '提出する'
    assert_text "6日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、6日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    assert_user_has_notification(user: users(:senpai), kind: Notification.kinds[:watching], text: "kensyuさんが「#{practices(:practice5).title}」の提出物を提出しました。")
  end

  test 'update product notification message for checker' do
    product = products(:product2)

    visit_with_auth "/products/#{product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end

    click_button '提出する'
    assert_text '提出物を更新しました。'

    assert_user_has_notification(user: users(:komagata), kind: Notification.kinds[:product_update], text: "kimuraさんの「#{product.practice.title}」の提出物が更新されました。")
  end
end
