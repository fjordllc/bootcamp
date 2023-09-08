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

  test 'copy and paste' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[description]', with: 'FBC')
    assert_field('report[description]', with: 'FBC')
    cmd_ctrl = page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
    find('.js-report-content').native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'x'])
    fill_in('report[description]', with: 'test')
    assert_field('report[description]', with: 'test')
    find('.js-report-content').native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'v'])
    assert_field('report[description]', with: 'FBC')
  end
  # test 'should automatically create Markdown link by pasting URL into selected text' do
  #   visit_with_auth new_report_path, 'komagata', dummy_clipboard: 'https://bootcamp.fjord.jp/'
  #   cmd_ctrl = page.driver.browser.capabilities.platform_name.include?('mac') ? :command : :control
  #   fill_in('report[description]', with: 'FBC')
  #   assert_field('report[description]', with: 'FBC')
  #   find('.js-report-content').native.send_keys([cmd_ctrl, 'a'], [cmd_ctrl, 'v'])
  #   assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
  # end
end
