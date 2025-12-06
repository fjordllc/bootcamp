# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownTest < ApplicationSystemTestCase
  test 'should remove script tag' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'script除去'
    fill_in 'page[body]', with: "scriptタグは削除される\n<script>alert('x')</script>"

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      assert_no_selector 'script'
    end
  end

  test 'javascript link is sanitized' do
    skip 'markdown-it-purifierの問題が解決したら戻す'

    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'リンク除去'
    fill_in 'page[body]', with: '<a href="javascript:alert(1)">リンク</a>'

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      assert_no_selector 'a[href^="javascript:"]'
      assert_text 'リンク'
    end
  end

  test 'blockquote tag is preserved when written as raw HTML' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'blockquoteテスト'
    fill_in 'page[body]', with: '<blockquote>引用です</blockquote>'

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      assert_selector 'blockquote'
      assert_text '引用です'
    end
  end

  test 'style attribute is preserved on allowed tags' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'style許可テスト'
    fill_in 'page[body]', with: '<p style="color: red;">赤文字</p>'

    click_button 'Docを公開'

    within '.a-long-text.is-md.js-markdown-view' do
      assert_selector 'p[style*="color"]', text: '赤文字'
    end
  end

  test 'should expand link card' do
    visit_with_auth new_report_path, 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'リンクカードが展開される')
      fill_in('report[description]', with: '@[card](https://bootcamp.fjord.jp/)')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_selector '.a-link-card'
    assert_no_selector 'a.before-replacement-link-card[href="https://bootcamp.fjord.jp/"]', visible: true
  end

  test 'should expand link card for tweet' do
    visit_with_auth new_report_path, 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'リンクカードが展開される')
      fill_in('report[description]', with: '@[card](https://x.com/fjordbootcamp/status/1866097842483503117)')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_selector '.twitter-tweet'
    assert_no_selector 'a.before-replacement-link-card[href="https://x.com/fjordbootcamp/status/1866097842483503117"]', visible: true
  end
end
