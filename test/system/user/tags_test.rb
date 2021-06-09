# frozen_string_literal: true

require 'application_system_test_case'

class User::TagsTest < ApplicationSystemTestCase
  setup { login_user 'hatsuno', 'testtest' }

  test 'search user by tag on user page' do
    user = users(:kimura)

    %i[cat shinjuku_rb neovim_v_zero_five_zero _net_framework may_j_].each do |key|
      name = acts_as_taggable_on_tags(key).name
      visit user_path(user)
      click_on name
      assert_text "タグ「#{name}」のユーザー"
      assert_text user.name
      assert_no_text "#{user.name}のプロフィール"
    end
  end

  test 'search user with user tag list' do
    user = users(:kimura)
    visit users_path

    %i[cat shinjuku_rb neovim_v_zero_five_zero _net_framework may_j_].each do |key|
      name = acts_as_taggable_on_tags(key).name
      within '.random-tags' do
        click_on name, exact_text: true
      end
      assert_text "タグ「#{name}」のユーザー"
      assert_text user.name
      assert_no_text '現役生'
    end
  end

  test 'add user tag' do
    visit user_path(users(:hatsuno))

    %i[cat shinjuku_rb neovim_v_zero_five_zero _net_framework may_j_].each do |key|
      name = acts_as_taggable_on_tags(key).name
      assert_no_text name

      visit "/users/tags/#{name}"
      click_on 'このタグを自分に追加'
      assert_no_text 'このタグを自分に追加'

      visit user_path(users(:hatsuno))
      assert_text name
    end
  end

  test 'edit user tag current_user page' do
    visit user_path users(:hatsuno)
    page.all('.tag-links__item-edit')[0].click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '課金'
    click_button '保存する'

    login_user 'komagata', 'testtest'
    visit user_path(users(:hatsuno))
    assert_text '課金'
    assert_no_text 'タグ編集'
  end
end
