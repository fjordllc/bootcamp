# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AfterRetirementTest < ApplicationSystemTestCase
  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @notice_text = 'komagataさんから回答がありました。'
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'three months have passed since user retired' do
    visit_with_auth '/scheduler/daily', 'komagata'
    visit '/notifications'

    within first('.card-list-item.is-unread') do
      assert_text 'taikai3さんが退会してから3カ月が経過しました。Discord ID: taikai#3333, ユーザーページ: https://bootcamp.fjord.jp/users/1008501353'
    end
  end
end
