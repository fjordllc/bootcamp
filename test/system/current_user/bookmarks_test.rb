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

  test 'show edit button and bookmarks when current user has bookmarks' do
    visit_with_auth '/current_user/bookmarks', 'kimura'

    assert_selector 'label', text: '編集'
    assert_selector 'input#card-list-tools__action', visible: false

    assert_text '作業週1日目'
    assert_selector '.card-list-item__label', text: '日報'
    assert_text '今日はローカルで怖話を動かしてみました。 rbenv で ruby を動かすのは初めてだったので、色々手間取りました。'
    assert_text 'komagata(コマガタ マサキ)'
    assert_text '2017年01月01日(日) 00:00'
  end

  test 'can delete bookmarks when edit mode is active' do
    visit_with_auth page_path(pages(:page1)), 'kimura'
    assert_text 'Bookmark中'

    visit_with_auth '/current_user/bookmarks', 'kimura'
    assert_selector '.card-list-item', count: 4
    assert_text 'test1'
    assert_no_selector '.bookmark-delete-button'

    find('#spec-edit-mode').click
    assert_selector '.bookmark-delete-button'
    first('.bookmark-delete-button').click

    assert_selector '.card-list-item', count: 3
    assert_no_text 'test1'

    visit_with_auth page_path(pages(:page1)), 'kimura'
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

  test 'no pagination when 20 bookmarks or less exist' do
    user_with_some_bookmarks = User.create!(
      login_name: 'have-some-bookmarks',
      email: 'have-some-bookmarks@fjord.jp',
      password: 'testtest',
      name: 'have-some-bookmarks',
      name_kana: 'ブックマーク タクサン',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experiences: 0
    )
    (1..20).each do |n|
      user_with_some_bookmarks.bookmarks.create!(bookmarkable_id: reports("report#{n}".to_sym).id, bookmarkable_type: 'Report')
    end
    visit_with_auth '/current_user/bookmarks', user_with_some_bookmarks.login_name
    # ページ遷移直後なのでreactコンポーネントが表示されるまで待つ
    within "[data-testid='bookmarks']" do
      assert_no_selector 'nav.pagination'
    end
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
    # ページ遷移直後なのでreactコンポーネントが表示されるまで待つ
    within "[data-testid='bookmarks']" do
      assert_selector 'nav.pagination', count: 2
    end

    first('.pagination__item-link', text: '2').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '2').count
    first('.pagination__item-link', text: '1').click
    assert_equal 2, page.all('.pagination__item-link.is-active', text: '1').count
  end
end
