# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::BookmarksTest < ApplicationSystemTestCase
  test 'show empty message and icon when current user has no bookmarks' do
    user_without_bookmark = User.create!(
      login_name: 'no-bookmarks',
      email: 'no-bookmarks@fjord.jp',
      password: 'testtest',
      name: 'no-bookmarks',
      name_kana: 'ブックマーク ナシ',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experiences: 0
    )
    visit_with_auth '/current_user/bookmarks', user_without_bookmark.login_name
    assert_text 'ブックマークはまだありません。'
    assert_selector 'i.fa-regular.fa-face-sad-tear', visible: false
    assert_no_selector 'input#card-list-tools__action', visible: false
  end

  test 'can delete bookmarks when edit mode is active' do
    page = pages(:page1)
    visit_with_auth page_path(page), 'kimura'
    wait_for_javascript_components
    assert_text 'Bookmark中'

    visit_with_auth '/current_user/bookmarks', 'kimura'

    initial_count = all('.card-list-item').size
    assert initial_count.positive?, 'ブックマークが表示されていません'
    assert_text page.title
    assert_no_selector '.bookmark-delete-button'

    find('#spec-edit-mode').click
    assert_selector '.bookmark-delete-button'
    within find('.card-list-item', text: page.title) do
      find('.bookmark-delete-button').click
    end

    assert_selector '.card-list-item', count: initial_count - 1
    assert_no_text page.title

    visit_with_auth page_path(page), 'kimura'
    wait_for_javascript_components
    assert_text 'Bookmark'
  end

  test 'show empty state when all bookmarks are deleted' do
    user_with_one_bookmark = User.create!(
      login_name: 'have-one-bookmark',
      email: 'have-one-bookmark@fjord.jp',
      password: 'testtest',
      name: 'have-one-bookmark',
      name_kana: 'ブックマーク イッケン',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experiences: 0
    )
    user_with_one_bookmark.bookmarks.create!(bookmarkable_id: reports(:report1).id, bookmarkable_type: 'Report')
    visit_with_auth '/current_user/bookmarks', user_with_one_bookmark.login_name

    assert_selector '.card-list-item', count: 1
    find('#spec-edit-mode').click
    first('.bookmark-delete-button').click

    assert_text 'ブックマークはまだありません。'
    assert_selector 'i.fa-regular.fa-face-sad-tear', visible: false
    assert_no_selector 'input#card-list-tools__action', visible: false
  end

  test 'show pagination when 21 bookmark or more exist' do
    user_with_many_bookmarks = User.create!(
      login_name: 'have-many-bookmarks',
      email: 'have-many-bookmarks@fjord.jp',
      password: 'testtest',
      name: 'have-many-bookmarks',
      name_kana: 'ブックマーク タクサン',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experiences: 0
    )
    (1..21).each do |n|
      user_with_many_bookmarks.bookmarks.create!(bookmarkable_id: reports("report#{n}".to_sym).id, bookmarkable_type: 'Report')
    end
    visit_with_auth '/current_user/bookmarks', user_with_many_bookmarks.login_name
    within '.page-main' do
      assert_selector 'nav.pagination', count: 2
    end

    first('.pagination__item-link', text: '2').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '2').count
    first('.pagination__item-link', text: '1').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '1').count
  end
end
