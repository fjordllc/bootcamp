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
    fill_in('report[description]', with: 'https://bootcamp.fjord.jp/')
    cmd_ctrl = page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
    find('.js-report-content').native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'x'])
    fill_in('report[description]', with: 'FBC')
    # クリップボードを読み取る権限を付与
    cdp_permission = {
      origin: page.server_url,
      permission: { name: 'clipboard-read' },
      setting: 'granted'
    }
    page.driver.browser.execute_cdp('Browser.setPermission', **cdp_permission)
    clip_text = page.evaluate_async_script('navigator.clipboard.readText().then(arguments[0])')
    assert_equal 'https://bootcamp.fjord.jp/', clip_text
    find('.js-report-content').native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'v'])
    sleep 5
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
  end
end
