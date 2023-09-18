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
    assert find('.js-user-icon.a-user-emoji')['data-user'].include?('mentormentaro')
  end

  test 'user profile image markdown test' do
    visit_with_auth new_page_path, 'komagata'
    fill_in 'page[title]', with: 'レポート'
    fill_in 'page[body]', with: ":@mentormentaro: \n すみません、これも確認していただけませんか？"

    click_button 'Docを公開'

    assert_css '.a-long-text.is-md.js-markdown-view'
    assert_css "a[href='/users/mentormentaro']"
    assert find('.js-user-icon.a-user-emoji')['data-user'].include?('mentormentaro')
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

  def cmd_ctrl
    page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
  end

  def all_cut(selector)
    find(selector).native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'x'])
  end

  def all_copy(selector)
    find(selector).native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'c'])
  end

  # CIでのみペースト前のctrl + Aが効かないため文字列の選択をselect()メソッドで実行
  # https://github.com/fjordllc/bootcamp/pull/6747#discussion_r1325419865
  # https://bootcamp.fjord.jp/questions/1720
  def select_text_and_paste(selector)
    page.execute_script("document.querySelector('#{selector}').select();")
    find(selector).native.send_keys([cmd_ctrl, 'v'])
  end

  def undo(selector)
    find(selector).native.send_keys([cmd_ctrl, 'z'])
  end

  def paste(selector)
    find(selector).native.send_keys([cmd_ctrl, 'v'])
  end

  test 'should automatically create Markdown link when pasting a URL text into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[description]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
    all_cut('#report_description')
    fill_in('report[description]', with: 'FBC')
    assert_field('report[description]', with: 'FBC')
    grant_clipboard_read_permission
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
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
    fill_in('report[description]', with: 'test')
    assert_field('report[description]', with: 'test')
    grant_clipboard_read_permission
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal 'FBC', clip_text
    select_text_and_paste('#report_description')
    assert_field('report[description]', with: 'FBC')
  end

  test 'should not create Markdown link when pasting a URL text without text selection' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[title]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[title]', with: 'https://bootcamp.fjord.jp/')
    all_copy('#report_title')
    grant_clipboard_read_permission
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    paste('#report_description')
    assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
  end
end
