# frozen_string_literal: true

require 'test_helper'

class ProductNotifierForPracticeWatcherTest < ActiveSupport::TestCase
  test '#call' do
    watch = watches(:practice1_watch_mentormentaro)
    product = products(:product70)
    byebug

    # 何をテストすればいいのか分からなくなった。
    # callの戻り値user（めんためんたろう）
    # notificationは作成されていない。なぜ。
    ProductNotifierForPracticeWatcher.new.call(product)

    assert Notification.where(kind: 17, user_id: product.user_id, sender_id: watch.user_id, message: "#{product.user}さんの提出物が更新されました", read: false,
                              link: "/products/#{product.id}").exists?
  end
end
