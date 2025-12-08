# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/tag_helper'

class PagesTest < ApplicationSystemTestCase
  include TagHelper

  setup do
    @raise_server_errors = Capybara.raise_server_errors
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'GET /pages' do
    visit_with_auth '/pages', 'kimura'
    assert_equal 'Docs | FBC', title
    assert_no_selector 'nav.pagination'
  end

  test 'show page' do
    visit_with_auth "/pages/#{pages(:page1).id}", 'kimura'
    assert_equal 'Docs: test1 | FBC', title
  end

  test 'show edit page' do
    visit_with_auth "/pages/#{pages(:page2).id}/edit", 'kimura'
    assert_equal 'ページ編集 | FBC', title
  end

  test 'page has a comment form ' do
    page = pages(:page1)
    visit_with_auth "/pages/#{page.id}", 'kimura'
    wait_for_comment_form
    assert_selector '.thread-comment-form'
  end

  test 'show comment count' do
    page = pages(:page1)
    visit_with_auth "/pages/#{page.id}", 'kimura'
    assert_selector '#comment_count', text: 0

    wait_for_comment_form
    post_comment('コメント数表示のテストです。')

    visit current_path
    wait_for_javascript_components
    assert_selector '#comment_count', text: 1
  end

  test 'show last updated user icon' do
    visit_with_auth "/pages/#{pages(:page7).id}", 'hajime'
    within '.a-meta.is-updater' do
      assert_selector 'img[alt="komagata (Komagata Masaki): 管理者、メンター"]'
    end
  end

  test 'show 404 page when accessed with slug does not exist in Docs' do
    Capybara.raise_server_errors = false

    slug = 'help12345'
    visit_with_auth "/pages/#{slug}", 'kimura'
    assert_text 'ActiveRecord::RecordNotFound'
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_page_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
