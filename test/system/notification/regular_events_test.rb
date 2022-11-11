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

  test 'Notify when a regular event change' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth "/regular_events/#{regular_event.id}/edit", 'komagata'
    within('form[name=regular_event]') do
      fill_in('regular_event[description]', with: 'updated')
    end
    click_button '内容変更'
    assert_text '定期イベントを更新しました。'

    visit_with_auth '/notifications', 'hatsuno'
    within first('.card-list-item.is-unread') do
      assert_text "定期イベント【#{regular_event.title}】が更新されました。"
    end
  end

end