# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::BookmarksTest < ApplicationSystemTestCase
  test 'show empty message and icon when current user has no bookmarks' do
    visit_with_auth '/current_user/bookmarks', 'nobookmarks'
    assert_text 'ブックマークはまだありません。'
    # tearアイコンが表示されることの確認は、fontawesomeの制約によりできないためスキップ
    # assert_selector 'i.fa-regular.fa-face-sad-tear'
    assert_no_selector 'input#card-list-tools__action', visible: false
  end

  test 'show edit button and bookmarks when current user has bookmarks' do
    visit_with_auth '/current_user/bookmarks', 'havealltypesofbookmarks'

    assert_selector 'label', text: '編集'
    assert_selector 'input#card-list-tools__action', visible: false

    assert_text '作業週1日目'
    assert_selector '.card-list-item__label', text: '日報'
    assert_text '今日はローカルで怖話を動かしてみました。rbenv で ruby を動かすのは初めてだったので、色々手間取りました。'
    assert_text 'Komagata Masaki'
    assert_text '2017年01月01日(日) 00:00'
  end

  test 'can delete bookmarks when edit mode is active' do
    visit_with_auth '/current_user/bookmarks', 'havealltypesofbookmarks'

    assert_selector '.card-list-item', count: 4
    assert_text 'test1'
    assert_no_selector '#bookmark-button'

    find('#spec-edit-mode').click
    assert_selector '#bookmark-button'
    all('#bookmark-button').first.click

    assert_selector '.card-list-item', count: 3
    assert_no_text 'test1'
  end

  test 'show empty state when all bookmarks are deleted' do
    visit_with_auth '/current_user/bookmarks', 'have_a_bookmark'

    assert_selector '.card-list-item', count: 1
    find('#spec-edit-mode').click
    first('#bookmark-button').click

    assert_text 'ブックマークはまだありません。'
    # tearアイコンが表示されることの確認は、fontawesomeの制約によりできないためスキップ
    # assert_selector 'i.fa-regular.fa-face-sad-tear'
    assert_no_selector 'input#card-list-tools__action', visible: false
  end
end
