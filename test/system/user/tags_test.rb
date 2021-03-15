# frozen_string_literal: true

require 'application_system_test_case'

class User::TagsTest < ApplicationSystemTestCase
  setup { login_user 'hatsuno', 'testtest' }

  test 'search user by tag on user page' do
    user = users(:kimura)

    %i[cat].each do |key|
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

    %i[cat].each do |key|
      name = acts_as_taggable_on_tags(key).name
      within '.popular-tags' do
        click_on name, exact_text: true
      end
      assert_text "タグ「#{name}」のユーザー"
      assert_text user.name
      assert_no_text '現役生'
    end
  end

  test 'add user tag' do
    visit user_path(users(:hatsuno))
    assert_no_text '猫'

    visit '/users/tags/猫'
    click_on 'このタグを自分に追加'
    assert_no_text 'このタグを自分に追加'

    visit user_path(users(:hatsuno))
    assert_text '猫'
  end
end
