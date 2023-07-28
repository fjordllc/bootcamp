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
    find('.js-report-content').native.send_keys([:command, 'a'], [:command, 'c'], :delete)
    fill_in('report[description]', with: 'FBC')
    find('.js-report-content').native.send_keys([:command, 'a'], [:command, 'v'])
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
  end

  test 'should support undo after automatically create Markdown link by pasting URL into selected text' do
    visit_with_auth new_report_path, 'komagata'
    fill_in('report[description]', with: 'https://bootcamp.fjord.jp/')
    find('.js-report-content').native.send_keys([:command, 'a'], [:command, 'c'], :delete)
    fill_in('report[description]', with: 'FBC')
    find('.js-report-content').native.send_keys([:command, 'a'], [:command, 'v'])
    assert_field('report[description]', with: '[FBC](https://bootcamp.fjord.jp/)')
    find('.js-report-content').native.send_keys([:command, 'z'])
    assert_field('report[description]', with: 'FBC')
  end
end
