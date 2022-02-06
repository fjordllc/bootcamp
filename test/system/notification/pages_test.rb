# frozen_string_literal: true

require 'application_system_test_case'

class Notification::PagesTest < ApplicationSystemTestCase
  test 'Only students and mentors are notified' do
    visit_with_auth '/pages', 'komagata'
    click_link 'Doc作成'

    within('.form') do
      fill_in('page[title]', with: 'DocsTest')
      fill_in('page[body]', with: 'DocsTestBody')
    end
    click_button '内容を保存'
    assert_text 'ページを作成しました。'

    visit_with_auth '/notifications', 'hatsuno'

    within first('.thread-list-item.is-unread') do
      assert_text 'komagataさんがDocsにDocsTestを投稿しました。'
    end

    visit_with_auth '/notifications', 'machida'

    within first('.thread-list-item.is-unread') do
      assert_text 'komagataさんがDocsにDocsTestを投稿しました。'
    end

    logout
    visit_with_auth '/notifications', 'yameo'
    assert_no_text 'komagataさんがDocsにDocsTestを投稿しました。'
  end

  test "don't notify when page is WIP" do
    visit_with_auth '/pages', 'komagata'
    click_link 'Doc作成'

    within('.form') do
      fill_in('page[title]', with: 'DocsTest')
      fill_in('page[body]', with: 'DocsTestBody')
    end
    click_button 'WIP'
    assert_text 'ページをWIPとして保存しました。'

    logout
    visit_with_auth '/notifications', 'hatsuno'
    assert_no_text 'komagataさんがDocsにDocsTestを投稿しました。'
  end

  test 'Notify Docs updated from WIP' do
    page = pages(:page5)
    visit_with_auth page_path(page), 'komagata'

    click_link '内容変更'
    click_button '内容を保存'
    assert_text 'ページを更新しました。'

    visit_with_auth '/notifications', 'machida'

    within first('.thread-list-item.is-unread') do
      assert_text 'komagataさんがDocsにWIPのテストを投稿しました。'
    end
  end
end
