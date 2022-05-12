# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class CurrentUserTest < ApplicationSystemTestCase
  include TagHelper

  test 'update user' do
    visit_with_auth '/current_user/edit', 'komagata'
    within 'form[name=user]' do
      fill_in 'user[login_name]', with: 'testuser'
      click_on '更新する'
    end
    assert_text 'ユーザー情報を更新しました。'
  end

  test 'update user tags' do
    visit_with_auth '/current_user/edit', 'komagata'
    tag_input = find '.ti-new-tag-input'
    tag_input.set 'タグ1'
    click_on '更新する'
    assert_text 'タグ1'

    visit '/users'
    assert_text 'タグ1'

    click_on 'タグ1'
    assert_text '「タグ1」のユーザー'
  end

  test 'update user description with blank' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in 'user[description]', with: ''
    click_on '更新する'
    assert_text '自己紹介を入力してください'
  end

  test 'alert when enter tag with space' do
    visit_with_auth edit_current_user_path, 'komagata'

    # この次に assert_alert_when_enter_one_dot_only_tag を追加しても、
    # 空白を入力したalertが発生し、ドットのみのalertが発生するテストにならない
    assert_alert_when_enter_tag_with_space
  end

  test 'alert when enter one dot only tag' do
    visit_with_auth edit_current_user_path, 'komagata'
    assert_alert_when_enter_one_dot_only_tag
  end

  test 'update times url with wrong url' do
    visit_with_auth '/current_user/edit', 'komagata'
    fill_in 'user[times_url]', with: 'https://example.com/channels/1234/5678/'
    click_button '更新する'
    assert_text '分報URLはDiscordのチャンネルURLを入力してください'
  end

  test 'Do not show after graduation hope when advisor' do
    visit_with_auth '/current_user/edit', 'hajime'
    assert_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
    visit_with_auth '/current_user/edit', 'senpai'
    assert_no_text 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを教えてください'
  end

  test 'should not show training end date if user is not trainee' do
    visit_with_auth edit_current_user_path, 'kimura'
    assert has_no_field?('user_training_ends_on')
  end

  test 'show training end date if user is trainee' do
    visit_with_auth edit_current_user_path, 'kensyu'
    assert has_field?('user_training_ends_on')
  end

  test 'update value of training end date' do
    training_ends_on = Date.current.next_year
    visit_with_auth edit_current_user_path, 'kensyu'
    fill_in 'user_training_ends_on', with: training_ends_on
    click_on '更新する'
    visit_with_auth edit_current_user_path, 'kensyu'
    assert has_field?('user_training_ends_on', with: training_ends_on)
  end

  test 'mentors advisors graduates admin can register their companies' do
    visit_with_auth '/current_user/edit', 'mentormentaro'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'advijirou'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'sotugyou'
    assert_text '企業'
    within '.choices__inner' do
      assert_text '所属なし'
    end

    visit_with_auth '/current_user/edit', 'komagata'
    assert_text '企業'
    within '.choices__inner' do
      assert_text 'Fjord Inc.'
    end
  end

  test 'not mentors advisors graduates admin can not register their companies' do
    visit_with_auth '/current_user/edit', 'kimura'
    assert_no_text '所属なし'
  end
end
