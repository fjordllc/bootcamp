# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownTest < ApplicationSystemTestCase
  test 'speak block test' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'インタビュー'
    fill_in 'page[body]', with: ":::speak @mentormentaro\n## 質問\nあああ\nいいい\n:::"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css '.speak'
    assert_css "a[href='/users/mentormentaro']"
    emoji = find('.js-user-icon.a-user-emoji')
    assert_includes emoji['title'], '@mentormentaro'
    assert_includes emoji['data-user'], 'mentormentaro'
  end

  test 'user profile image markdown test' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'レポート'
    fill_in 'page[body]', with: ":@mentormentaro: \n すみません、これも確認していただけませんか？"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css "a[href='/users/mentormentaro']"
    emoji = find('.js-user-icon.a-user-emoji')
    assert_includes emoji['title'], '@mentormentaro'
    assert_includes emoji['data-user'], 'mentormentaro'
  end

  # TODO: 動画機能が実装されたら削除する
  test 'should convert private vimeo url' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[body]', with: '(https://vimeo.com/0000000000/1aaaaaaaaa)'
    assert page.has_content?('(0000000000?h=1aaaaaaaaa)')
  end

  def cmd_ctrl
    page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
  end

  def all_copy(selector)
    find(selector).native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'c'])
  end

  # headless chromeでnavigator.clipboard.readText()を実行する時に必要
  # https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325417231
  # https://bootcamp.fjord.jp/reports/80292
  def grant_clipboard_read_permission
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
  end

  def read_clipboard_text
    page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
  end

  def paste(selector)
    find(selector).native.send_keys([cmd_ctrl, 'v'])
  end

  # CIでのみペースト前のctrl + Aが効かないため文字列の選択をselect()メソッドで実行
  # https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325419865
  # https://bootcamp.fjord.jp/questions/1720
  def select_text_and_paste(selector)
    page.execute_script("document.querySelector('#{selector}').select();")
    paste(selector)
  end

  def undo(selector)
    find(selector).native.send_keys([cmd_ctrl, 'z'])
  end

  test 'should automatically create Markdown link when pasting a URL text into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    fill_in('report[description]', with: 'FBC')
    assert_field('report[description]', with: 'FBC')
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
    undo('#report_description')
    assert_field('report[description]', with: 'FBC')
  end

  test 'should not create Markdown link when pasting non-URL text into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'FBC')
    assert_field('report[title]', with: 'FBC')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'FBC', clip_text
    fill_in('report[description]', with: 'test')
    assert_field('report[description]', with: 'test')
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: 'FBC')
  end

  test 'should not create Markdown link when pasting a URL text without text selection' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    paste('#report_description')
    assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
  end

  test 'should escape square brackets in the selected text when pasting a URL text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = read_clipboard_text
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    fill_in('report[description]', with: '[]')
    assert_field('report[description]', with: '[]')
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: '[\[\]](https://bootcamp.fjord.jp/)')
  end
end
