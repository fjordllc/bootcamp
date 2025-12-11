# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::TagsTest < ApplicationSystemTestCase
  test 'update user tags' do
    visit_with_auth '/current_user/edit', 'komagata'
    tag_input = find '.tagify__input'
    tag_input.set ''
    tag_input.set 'タグ1'
    tag_input.native.send_keys :enter
    assert_text 'タグ1'
    find_all('.tagify__tag').map(&:text)
    click_on '更新する'
    assert_text 'タグ1'

    visit '/users'
    assert_text 'タグ1'

    click_on 'タグ1'
    assert_text '「タグ1」のユーザー'
  end

  test 'alert when enter tag with space' do
    visit_with_auth edit_current_user_path, 'komagata'
    ['半角スペースは 使えない', '全角スペースも　使えない'].each do |tag|
      fill_in_tag_with_alert tag
    end
    click_on '更新する'
    assert_equal users(:komagata).tag_list.sort,
                 all('.tag-links__item-link').map(&:text).sort
  end

  test 'alert when enter one dot only tag' do
    visit_with_auth edit_current_user_path, 'komagata'
    fill_in_tag_with_alert '.'
    click_on '更新する'
    assert_equal users(:komagata).tag_list.sort,
                 all('.tag-links__item-link').map(&:text).sort
  end
end
