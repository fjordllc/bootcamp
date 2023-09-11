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

  test 'should automatically create Markdown link by pasting URL into selected text' do
    visit_with_auth new_report_path, 'komagata'
    el = find('.js-report-content').native
    fill_in('report[description]', with: 'https://bootcamp.fjord.jp/')
    assert_field('report[description]', with: 'https://bootcamp.fjord.jp/')
    cmd_ctrl = page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
    # 文字列を選択→カット
    page.driver.browser.action
        .key_down(el, :shift)
        .send_keys(el, :arrow_up)
        .key_up(el, :shift)
        .key_down(el, cmd_ctrl)
        .send_keys(el, 'x')
        .key_up(el, cmd_ctrl)
        .perform
    fill_in('report[description]', with: 'FBC')
    assert_field('report[description]', with: 'FBC')
    # クリップボードを読み取る権限を付与
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    focused_element_id = page.evaluate_script('document.activeElement.id')
    assert_equal 'report_description', focused_element_id
    # 文字列を選択→ペースト
    page.driver.browser.action
        .key_down(el, :shift)
        .send_keys(el, :arrow_up)
        .key_up(el, :shift)
        .key_down(el, cmd_ctrl)
        .send_keys(el, 'v')
        .key_up(el, cmd_ctrl)
        .perform
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
    find('.js-report-content').native.send_keys([cmd_ctrl, 'z'])
    assert_field('report[description]', with: 'FBC')
  end
end
