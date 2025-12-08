# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class ValidationTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    end

    test 'cannot post a new report with future date' do
      visit_with_auth '/reports/new', 'komagata'
      within('form[name=report]') do
        fill_in('report[title]', with: '学習日が未来日では日報を作成できない')
        fill_in('report[description]', with: 'エラーになる')
        fill_in('report[reported_on]', with: Date.current.next_day)
      end
      click_button '提出'
      assert_text '学習日は2013年01月01日から今日以前の間の日付にしてください'
    end

    test 'cannot post a new report with min date' do
      visit_with_auth '/reports/new', 'komagata'
      within('form[name=report]') do
        fill_in('report[title]', with: '学習日が2013年1月1日より前では日報を作成できない')
        fill_in('report[description]', with: 'エラーになる')
        fill_in('report[reported_on]', with: Date.new(2012, 12, 31))
      end
      click_button '提出'
      html_validation_message = page.find('#report_reported_on').native.attribute('validationMessage')
      assert_not_nil html_validation_message
      assert_not_empty html_validation_message
    end

    test 'practices are displayed when updating with selecting a practice' do
      report = reports(:report10)
      visit_with_auth "/reports/#{report.id}", 'hajime'
      click_link '内容修正'

      click_button '内容変更'
      assert_text 'Terminalの基礎を覚える'
      assert_text '日報を保存しました。'
    end

    test 'practices are not displayed when updating without selecting a practice' do
      report = reports(:report10)
      visit_with_auth "/reports/#{report.id}", 'hajime'
      click_link '内容修正'
      first('.choices__button').click

      click_button '内容変更'
      assert_no_text 'Terminalの基礎を覚える'
      assert_text '日報を保存しました。'
    end

    test 'equal practices order in practices and new report' do
      visit_with_auth '/reports/new', 'komagata'
      first('.choices__inner').click
      report_practices = page.all('.choices__item--choice').map(&:text)
      current_user = users(:komagata)
      category_ids = current_user.course.category_ids
      assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).distinct.count
      assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
      assert_match(/企業研究/, all('.choices__item--choice').last.text)
    end

    test 'equal practices order in practices and edit report' do
      visit_with_auth "/reports/#{reports(:report1).id}/edit", 'komagata'
      first('.choices__inner').click
      report_practices = page.all('.choices__item--choice').map(&:text)
      current_user = users(:komagata)
      category_ids = current_user.course.category_ids
      assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).distinct.count
      assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
      assert_match(/企業研究/, all('.choices__item--choice').last.text)
    end

    test 'select box shows the practices that belong to a user course' do
      visit_with_auth reports_path, 'kimura'
      first('.choices__inner').click
      page_practices = page.all('.choices__item--choice').map(&:text).size
      course_practices = users(:kimura).course.practices.size + 1
      assert_equal page_practices, course_practices
    end
  end
end
