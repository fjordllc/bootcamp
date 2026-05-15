# frozen_string_literal: true

require 'application_system_test_case'

module Users
  class ListTest < ApplicationSystemTestCase
    test 'show listing all users' do
      visit_with_auth users_path, 'kimura'
      assert_equal '全てのユーザー | FBC', title
      assert_selector 'h2.page-header__title', text: 'ユーザー'
    end

    test 'admin can see link to talk on user list page' do
      visit_with_auth '/users', 'komagata'
      assert_selector '.page-header__title', text: 'ユーザー'
      assert_link '相談部屋'
    end

    test 'not admin cannot see link to talk on user list page' do
      visit_with_auth '/users', 'kimura'
      assert_selector '.page-header__title', text: 'ユーザー'
      assert_no_link '相談部屋'
    end

    test 'show trainees for adviser' do
      visit_with_auth "/users/#{users(:kensyu).id}", 'senpai'
      assert_text '自社研修生'
      assert_no_text 'フォローする'
      assert_no_text '登録情報変更'
    end

    test 'show students' do
      visit_with_auth "/users/#{users(:kensyu).id}", 'hatsuno'
      assert_no_text '自社研修生'
      assert_text 'フォローする'
      assert_no_text '登録情報変更'
    end

    test 'show no trainees for adviser' do
      visit_with_auth "/users/#{users(:hatsuno).id}", 'senpai'
      assert_no_text '自社研修生'
      assert_text 'フォローする'
      assert_no_text '登録情報変更'
    end

    test 'show myself' do
      visit_with_auth "/users/#{users(:kensyu).id}", 'kensyu'
      assert_no_text '自社研修生'
      assert_no_text 'フォローする'
      assert_text '登録情報変更'
    end

    test 'show users trainees for adviser' do
      visit_with_auth '/users?target=trainee', 'senpai'
      assert_text '自社研修生'
    end

    test 'mentor can see retired and hibernated tabs' do
      visit_with_auth '/users', 'mentormentaro'
      assert_link '休会', href: '/users?target=hibernated'
      assert_link '退会', href: '/users?target=retired'
    end

    test 'admin can see retired and hibernated tabs' do
      visit_with_auth '/users', 'komagata'
      assert_link '休会', href: '/users?target=hibernated'
      assert_link '退会', href: '/users?target=retired'
    end

    test 'user can not see retired and hibernated tabs if the user is not admin or mentor' do
      visit_with_auth '/users', 'sotugyou'
      assert_no_link '休会', href: '/users?target=hibernated'
      assert_no_link '退会', href: '/users?target=retired'
    end

    test "should show students and trainees's active activity counts" do
      visit_with_auth users_path, 'kimura'
      assert_selector '.card-counts__item-value', text: '0'

      click_link('卒業生')
      assert_selector '.card-counts__item-value', text: '0'

      click_link('研修生')
      assert_selector '.card-counts__item-value', text: '0'
    end

    test "should show hibernated user and retired user's activity counts" do
      visit_with_auth users_path, 'komagata'
      click_link('休会')
      assert_selector '.card-counts__item-value', text: '0'

      click_link('退会')
      assert_selector '.card-counts__item-value', text: '0'
    end

    test "should not show mentor and adviser's activity counts" do
      visit_with_auth users_path, 'kimura'
      click_link('メンター')
      assert_no_selector '.card-counts__items'

      click_link('アドバイザー')
      assert_no_selector '.card-counts__items'
    end

    test 'show retirement message on users page' do
      visit_with_auth users_path, 'komagata'
      click_link('退会')
      assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message', text: '退会しました'
    end

    test 'show hibernation elapsed days message on users page' do
      travel_to Time.zone.local(2020, 1, 11, 0, 0, 0) do
        visit_with_auth users_path, 'komagata'
        click_link('休会')
        assert_selector '.users-item__inactive-message-container.is-only-mentor .users-item__inactive-message',
                        text: '休会中: 2020年01月01日〜(10日経過)'
      end
    end

    test 'students and trainees filter' do
      visit_with_auth '/users', 'komagata'
      click_link '現役 + 研修生'

      assert_selector('a.tab-nav__item-link.is-active', text: '現役 + 研修生')
      filtered_users = all('.users-item__icon .a-user-role')
      assert(filtered_users.all? do |user|
        classes = user[:class].split
        classes.include?('is-student') || classes.include?('is-trainee')
      end)
    end

    test 'students filter' do
      visit_with_auth '/users', 'komagata'
      click_link '現役生'

      assert_selector('a.tab-nav__item-link.is-active', text: '現役生')
      filtered_users = all('.users-item__icon .a-user-role')
      assert(filtered_users.all? { |user| user[:class].split.include?('is-student') })
    end
  end
end
