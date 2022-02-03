# frozen_string_literal: true

require 'application_system_test_case'

class Notification::ProductsTest < ApplicationSystemTestCase
  test 'send adviser a notification when trainee create product' do
    visit_with_auth "/products/new?practice_id=#{practices(:practice5).id}", 'kensyu'

    within('#new_product') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"

    visit_with_auth '/notifications', 'senpai'

    within first('.thread-list-item.is-unread') do
      assert_text "kensyuさんが「#{practices(:practice5).title}」の提出物を提出しました。"
    end
  end

  test 'update product notificationmessage' do
    product = products(:product2)

    visit_with_auth "/products/#{product.id}/edit", 'kimura'
    within('form[name=product]') do
      fill_in('product[body]', with: 'test')
    end
    click_button '提出する'
    assert_text '提出物を更新しました。'

    visit_with_auth '/notifications', 'komagata'

    within first('.thread-list-item.is-unread') do
      assert_text 'kimuraさんの提出物が更新されました'
    end
  end
end
