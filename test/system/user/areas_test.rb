# frozen_string_literal: true

require 'application_system_test_case'

class User::AreasTest < ApplicationSystemTestCase
  test 'show users devided by areas' do
    visit_with_auth '/users/areas', 'komagata'
    assert_equal '都道府県別ユーザー一覧 | FBC', title
    within "[data-testid='areas']" do
      assert_text '関東地方'
      assert_selector "[data-login-name='kimura']"
    end
  end
end
