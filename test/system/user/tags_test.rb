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
      assert_no_text 'プロフィール'
    end
  end

  test 'search user with user tag list' do
    user = users(:kimura)
    visit_with_auth users_path, 'kimura'

    %i[cat shinjuku_rb neovim_v_zero_five_zero _net_framework may_j_].each do |key|
      name = acts_as_taggable_on_tags(key).name
      within '.random-tags' do
        find('a.random-tags-item__link', text: /^#{name}$/).click
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
    tag_input = find('.tagify__input')
    tag_input.set 'タグタグ'
    tag_input.native.send_keys :return
    Timeout.timeout(Capybara.default_max_wait_time, StandardError) do
      loop until page.has_text?('タグタグ')
    end
    find_all('.tagify__tag').map(&:text)
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

  test 'admin can edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth users_tag_path(tag.name, all: 'true'), 'komagata'
    assert_text('タグ名変更')
  end

  test 'users except admin cannot edit tag' do
    tag = acts_as_taggable_on_tags('game')
    visit_with_auth users_tag_path(tag.name, all: 'true'), 'kimura'
    assert_no_text('タグ名変更')
  end

  test 'update tag with not existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag_text = '上級者'

    visit_with_auth users_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag_text)
    click_button '変更'
    assert_text 'タグ「上級者」'

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag_text), 'komagata'
    assert_text "タグ「#{update_tag_text}」のユーザー（1）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('card-list-item')
    visit_with_auth pages_tag_path(update_tag_text), 'komagata'
    has_selector?('card-list-item')
  end

  test 'update tag with existing tag' do
    tag = acts_as_taggable_on_tags('beginner')
    update_tag = acts_as_taggable_on_tags('intermediate')

    visit_with_auth users_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: update_tag.name)
    click_button '変更'
    assert_text 'タグ「中級者」'

    visit_with_auth users_tag_path(tag.name), 'komagata'
    assert_text "#{tag.name}のユーザーはいません"
    visit_with_auth users_tag_path(update_tag.name), 'komagata'
    assert_text "タグ「#{update_tag.name}」のユーザー（2）"

    visit_with_auth pages_tag_path(tag.name), 'komagata'
    has_no_selector?('card-list-item')
    visit_with_auth pages_tag_path(update_tag.name), 'komagata'
    has_selector?('card-list-item')
  end

  test 'update tag with same value' do
    tag = acts_as_taggable_on_tags('beginner')

    visit_with_auth users_tag_path(tag.name, all: 'true'), 'komagata'
    click_button 'タグ名変更'
    fill_in('tag[name]', with: tag.name)
    has_field?('変更', disabled: true)
  end

  test 'the first letter is ignored when adding a tag whose name begins with octothorpe' do
    visit_with_auth user_path(users(:hatsuno)), 'hatsuno'
    first('.tag-links__item-edit').click
    tag_input = find('.tagify__input')
    tag_input.set '#ハッシュハッシュ'
    tag_input.native.send_keys :return
    click_button '保存する'

    assert_includes all('.tag-links__item-link').map(&:text), 'ハッシュハッシュ'
  end

  test 'hibernated users are displayed in the user list by tag' do
    user = users(:kensyu)
    tag_name = acts_as_taggable_on_tags('guitar').name.to_s

    User.tags.where.not(name: tag_name).destroy_all

    visit_with_auth users_tag_path(tag_name), 'kensyu'
    assert_text "タグ「#{tag_name}」のユーザー（2）"
    assert_selector ".users-item__icon img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth users_tags_path, 'kensyu'
    displayed_users_number = find('.user-group__count').text[/\d+/]
    assert_equal '2', displayed_users_number
    assert_selector ".a-user-icons__items img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth new_hibernation_path, 'kensyu'
    within('form[name=hibernation]') do
      fill_in(
        'hibernation[scheduled_return_on]',
        with: (Date.current + 30)
      )
      fill_in('hibernation[reason]', with: 'test')
    end
    find('.check-box-to-read').click
    click_on '休会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '休会手続きが完了しました'

    visit_with_auth users_tag_path(tag_name), 'komagata'
    assert_text "タグ「#{tag_name}」のユーザー（1）"
    assert_no_selector ".users-item__icon img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth users_tags_path, 'komagata'
    displayed_users_number = find('.user-group__count').text[/\d+/]
    assert_equal '1', displayed_users_number
    assert_no_selector ".a-user-icons__items img[title='#{user.login_name} (#{user.name})']"
  end

  test 'retired users are displayed in the user list by tag' do
    user = users(:kensyu)
    tag_name = acts_as_taggable_on_tags('guitar').name.to_s

    User.tags.where.not(name: tag_name).destroy_all

    visit_with_auth users_tag_path(tag_name), 'kensyu'
    assert_text "タグ「#{tag_name}」のユーザー（2）"
    assert_selector ".users-item__icon img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth users_tags_path, 'kensyu'
    displayed_users_number = find('.user-group__count').text[/\d+/]
    assert_equal '2', displayed_users_number
    assert_selector ".a-user-icons__items img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth new_retirement_path, 'kensyu'
    find('label', text: 'とても良い').click
    click_on '退会する'
    page.driver.browser.switch_to.alert.accept
    assert_text '退会処理が完了しました'

    visit_with_auth users_tag_path(tag_name), 'komagata'
    assert_text "タグ「#{tag_name}」のユーザー（1）"
    assert_no_selector ".users-item__icon img[title='#{user.login_name} (#{user.name})']"

    visit_with_auth users_tags_path, 'komagata'
    displayed_users_number = find('.user-group__count').text[/\d+/]
    assert_equal '1', displayed_users_number
    assert_no_selector ".a-user-icons__items img[title='#{user.login_name} (#{user.name})']"
  end
end
