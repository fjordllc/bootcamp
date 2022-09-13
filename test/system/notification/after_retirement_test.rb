# frozen_string_literal: true

require 'application_system_test_case'

class Notification::AfterRetirementTest < ApplicationSystemTestCase
  test 'three months have passed since user retired' do
    visit_with_auth '/scheduler/daily', 'komagata'
    visit '/notifications'

    assert_selector 'h2', text: 'taikai3さんが退会してから3カ月が経過しました。Discord ID:taikai#3333, ユーザーページ:https://bootcamp.fjord.jp/users/1008501353'
  end
end
