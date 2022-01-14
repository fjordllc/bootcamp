# frozen_string_literal: true

require 'application_system_test_case'

class User::TagsTest < ApplicationSystemTestCase
  test 'search user by tag on user page' do
    user = users(:kimura)

    %i[cat shinjuku_rb neovim_v_zero_five_zero _net_framework may_j_].each do |key|
      name = acts_as_taggable_on_tags(key).name
      visit_with_auth user_path(user), 'hatsuno'
      click_on name
      assert_text "タグ「#{name}」のユーザー"
      assert_text user.name
      assert_no_text "#{user.name}のプロフィール"
    end
  end

  test 'search user with user tag list' do
    user = users(:kimura)
    visit_with_auth users_path, 'kimura'

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
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'

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
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'
    page.all('.tag-links__item-edit')[0].click
    tag_input = find('.ti-new-tag-input')
    tag_input.set 'タグタグ'
    find('body').click
    click_button '保存する'

    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_text 'タグタグ'
    assert_no_text 'タグ編集'
  end

  test 'delete user tag on tag page' do
    visit_with_auth user_path(users(:hajime)), 'hajime'
    name = acts_as_taggable_on_tags('cat').name
    assert_text name

    visit "/users/tags/#{name}"
    click_link 'このタグを自分から外す'
    assert_no_text 'このタグを自分から外す'
    visit user_path(users(:hajime))
    assert_no_text name
  end

  test 'the first letter is ignored when adding a tag whose name begins with octothorpe' do
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'
    page.all('.tag-links__item-edit')[0].click
    tag_input = find('.ti-new-tag-input')
    tag_input.set '#ハッシュハッシュ'
    find('body').click
    click_button '保存する'

    visit_with_auth user_path(users(:hatsuno)), 'komagata'
    assert_no_text '#ハッシュハッシュ'
    assert_text 'ハッシュハッシュ'
  end
end
