# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AfterRetirementTest < ApplicationSystemTestCase
  test 'three months have passed since user retired' do
    visit_with_auth '/scheduler/daily', 'komagata'

    visit '/'
    open_notification
    assert_equal 'taikai3さんが退会してから3カ月が経過しました。Discord ID: taikai#3333, ユーザーページ: https://bootcamp.fjord.jp/users/1008501353',
                 notification_message
  end
end
