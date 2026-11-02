# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownWikiLinkTest < ApplicationSystemTestCase
  test 'wiki links preview and navigate to a Doc by slug on the same tab' do
    assert_wiki_link_navigation pages(:page10), pages(:page10).slug
  end

  test 'wiki links preview and navigate to a Doc by numeric ID on the same tab' do
    assert_wiki_link_navigation pages(:page1), pages(:page1).id.to_s
  end

  private

  def assert_wiki_link_navigation(destination, label)
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'Wikiリンクのテスト'
    fill_wiki_link_body(label)

    within '.js-preview' do
      assert_selector "a[href='/pages/#{label}']", text: label, exact_text: true
      assert_selector "a[href='/pages/AAA']", text: 'AAA', exact_text: true
      assert_selector 'a', text: '*用語* :smile: @komagata', exact_text: true
      assert_no_selector 'a[target="_blank"]'
    end

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      assert_selector "a[href='/pages/#{label}']", text: label, exact_text: true
      assert_selector "a[href='/pages/AAA']", text: 'AAA', exact_text: true
      assert_selector 'a', text: '*用語* :smile: @komagata', exact_text: true
      assert_no_selector 'a[target="_blank"]'
      find_link(label, exact: true).send_keys(:enter)
    end

    assert_current_path page_path(label)
    assert_selector 'h1', text: destination.title
    assert_equal 1, windows.size
  end

  def fill_wiki_link_body(label)
    fill_in 'page[body]', with: "参照: [[#{label}]] と [[AAA]] と [[*用語* :smile: @komagata]]"
    find_field('page[body]').send_keys(:end)
  end
end
