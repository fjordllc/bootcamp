# frozen_string_literal: true

require 'test_helper'

class PageWatchersTest < ActionDispatch::IntegrationTest
  setup do
    @pages = [pages(:page1), pages(:page2)]
    post user_sessions_path, params: { user: { login: 'machida', password: 'testtest' } }
  end

  test 'editor who is not the author becomes a watcher' do
    editor = users(:machida)
    @pages.each { |page| assert_not editor.watches.exists?(watchable: page) }

    patch page_path(@pages[0]), params: { page: { title: @pages[0].title }, commit: '内容を更新' }
    patch page_path(@pages[1]), params: { page: { title: @pages[1].title }, commit: 'WIP' }

    assert @pages[1].reload.wip?
    @pages.each { |page| assert editor.watches.exists?(watchable: page) }
  end

  test 'author becomes a watcher when another user sets the author' do
    author = users(:kimura)
    @pages.each { |page| assert_not author.watches.exists?(watchable: page) }

    patch page_path(@pages[0]), params: { page: { user_id: author.id }, commit: '内容を更新' }
    patch page_path(@pages[1]), params: { page: { user_id: author.id }, commit: 'WIP' }

    @pages.each do |page|
      assert_equal author, page.reload.user
      assert author.watches.exists?(watchable: page)
    end
  end
end
