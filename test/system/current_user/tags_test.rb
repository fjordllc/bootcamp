# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::TagsTest < ApplicationSystemTestCase
  test 'update user tags' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in_tag 'タグ1'
    assert_text 'タグ1'
    click_on '更新する'
    assert_text 'タグ1'

    visit '/users'
    assert_text 'タグ1'

    click_on 'タグ1'
    assert_text '「タグ1」のユーザー'
  end
end
