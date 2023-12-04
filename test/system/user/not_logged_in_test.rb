# frozen_string_literal: true

require 'application_system_test_case'

class User::NotLoggedInTest < ApplicationSystemTestCase
  test 'appropriate meta description is displayed when accessed by non-logged-in user' do
    target_user = users(:kimura)
    visit user_path(target_user)
    assert_selector 'head', visible: false do
      assert_selector "meta[name='description'][content='オンラインプログラミングスクール「フィヨルドブートキャンプ」の#{target_user.login_name}さんのプロフィールページ']", visible: false
    end
  end
end
