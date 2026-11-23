# frozen_string_literal: true

require 'application_system_test_case'

class Admin::UsersTest < ApplicationSystemTestCase
  # 一覧の絞り込みと、画面の操作に頼らない更新は test/integration/admin/user_management_test.rb で確かめる。
  test 'update user' do
    user = users(:hatsuno)
    reset_avatar(user)
    visit_with_auth "/users/#{user.id}", 'komagata'
    icon_before = find('img.user-profile__user-icon-image', visible: false)
    before_src = icon_before.native['src']

    visit "/admin/users/#{user.id}/edit"
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'hatsuno'
      attach_file 'user[avatar]', 'test/fixtures/files/users-avatars-komagata.jpg', make_visible: true
      click_on '更新する'
    end

    assert_text 'ユーザー情報を更新しました。'
    visit "/users/#{user.id}"
    icon_after = find('img.user-profile__user-icon-image', visible: false)
    after_src = icon_after.native['src']

    # アバターが更新されたことを確認（URLが変わったことで確認）
    assert_not_equal before_src, after_src
    # タイムスタンプパラメータが含まれていることを確認
    assert_match(/\?v=\d+/, after_src)
  end

  test 'shows Font Awesome at icons on user edit form mention inputs' do
    user = users(:komagata)
    user.update!(github_id: '1234567890')
    visit_with_auth edit_admin_user_path(user.id), 'komagata'

    assert_selector '.form-item__mention-input', count: 3
    all('.form-item__mention-input').each do |mention_input|
      before_style = mention_input.evaluate_script(<<~JS)
        (() => {
          const style = getComputedStyle(this, '::before')
          return { content: style.content, fontFamily: style.fontFamily, fontWeight: style.fontWeight }
        })()
      JS

      assert_equal '"@"', before_style['content']
      assert_match(/Font Awesome 7 Free/, before_style['fontFamily'])
      assert_equal '900', before_style['fontWeight']
    end
  end

  test 'update user with company' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    within 'form[name=user]' do
      find('.choices').click
      first('.choices__item', text: 'Lokka Inc.').click
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
    visit "/users/#{user.id}"
    found_value = all('.user-metas__item-value').find { |element| element.text.include?('Lokka Inc.') }
    assert_not_nil(found_value, "Expected to find '.user-metas__item-value' with text 'Lokka Inc.'")
  end

  test 'hide input for retire date when unchecked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_unchecked_field?('retire_checkbox', visible: false)
    assert_no_selector '#user_retired_on'
  end

  test 'show input for retire date when checked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    check 'retire_checkbox', allow_label_click: true
    assert_selector '#user_retired_on'
  end

  test 'show input for retire date if user is retired' do
    user = users(:yameo)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('retire_checkbox', visible: false)
    assert has_field?('user_retired_on', with: user.retired_on.to_s)
  end

  test 'reset value of retire date when unchecked' do
    user = users(:yameo)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('retire_checkbox', visible: false)
    uncheck 'retire_checkbox', allow_label_click: true
    assert has_unchecked_field?('retire_checkbox', visible: false)
    check 'retire_checkbox', allow_label_click: true
    assert has_field?('user_retired_on', with: '')
  end

  test 'hide input for graduation date when unchecked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_unchecked_field?('graduation_checkbox', visible: false)
    assert_no_selector '#user_graduated_on'
  end

  test 'show input for graduation date when checked' do
    user = users(:hatsuno)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    check 'graduation_checkbox', allow_label_click: true
    assert_selector '#user_graduated_on'
  end

  test 'show input for graduation date if user is graudated' do
    user = users(:sotugyou)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert has_checked_field?('graduation_checkbox', visible: false)
    assert has_field?('user_graduated_on', with: user.graduated_on.to_s)
  end

  test 'reset value of graduation date when unchecked' do
    user = users(:sotugyou)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    uncheck 'graduation_checkbox', allow_label_click: true
    assert has_unchecked_field?('graduation_checkbox', visible: false)
    check 'graduation_checkbox', allow_label_click: true
    assert has_field?('user_graduated_on', with: '')
  end

  test 'edit user tag' do
    user = users(:kimura)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    fill_in_tag('追加タグ')
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました。'
    assert_includes user.reload.tag_list, '追加タグ'
  end

  test 'should not show training end date if user is not trainee' do
    user = users(:kimura)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    assert has_unchecked_field?('checkbox_trainee', visible: false)
    assert has_no_field?('user_training_ends_on')
  end

  test 'reset value of training end date when unchecked' do
    user = users(:kensyu)
    visit_with_auth edit_admin_user_path(user.id), 'komagata'
    uncheck 'checkbox_trainee', allow_label_click: true
    assert has_unchecked_field?('checkbox_trainee', visible: false)
    assert_selector '.js-training-info-block', visible: :hidden
    check 'checkbox_trainee', allow_label_click: true
    assert has_checked_field?('checkbox_trainee', visible: false)
    assert has_field?('user_training_ends_on', with: '')
  end

  test 'administrator can set skipped_practice of general users' do
    user = users(:kensyu)
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'UNIX (1/9)', normalize_ws: true
    check 'UNIX', allow_label_click: true
    check 'Terminalの基礎を覚える', allow_label_click: true
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました'
    visit_with_auth "/admin/users/#{user.id}/edit", 'komagata'
    assert_text 'UNIX (2/9)', normalize_ws: true
  end

  test 'admin can delete diploma file' do
    user = users(:kimura)
    visit_with_auth edit_admin_user_path(user), 'komagata'
    attach_file 'user[diploma_file]', file_fixture('users/diplomas/diploma.pdf'), visible: false
    click_button '更新する'
    assert_text 'ユーザー情報を更新しました'
    assert user.reload.diploma_file.attached?
    visit edit_admin_user_path(user)
    click_on '削除'
    click_on '更新する'
    assert_text 'ユーザー情報を更新しました'
    assert_not user.reload.diploma_file.attached?
    visit edit_admin_user_path(user)
    assert_no_link 'diploma.pdf'
  end
end
