# frozen_string_literal: true

require 'application_system_test_case'

module Reports
  class MarkdownTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/introduction')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    end

    test 'reports can be checked as plain markdown' do
      visit_with_auth '/reports/new', 'kimura'
      within('form[name=report]') do
        fill_in('report[title]', with: 'check plain markdown')
        fill_in('report[description]', with: '## this is heading2')
        fill_in('report[reported_on]', with: Time.current)
      end

      all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
      all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
      all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
      all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

      click_button '提出'
      click_link 'Raw'
      switch_to_window windows.last
      assert_text '## this is heading2', exact: true
    end

    test 'description of the daily report is previewed' do
      visit_with_auth '/reports/new', 'komagata'
      within('form[name=report]') do
        fill_in('report[description]', with: "Markdown入力するとプレビューにHTMLで表示されている。\n # h1")
      end
      assert_selector '.js-preview.a-long-text.markdown-form__preview', text: 'Markdown入力するとプレビューにHTMLで表示されている。' do
        assert_selector 'h1', text: 'h1'
      end
    end

    test 'description of the daily report is previewed when editing' do
      visit_with_auth report_path(reports(:report1)), 'komagata'
      click_link '内容修正'
      within('form[name=report]') do
        fill_in('report[description]', with: "Markdown入力するとプレビューにHTMLで表示されている。\n # h1")
      end
      assert_selector '.js-preview.markdown-form__preview', text: 'Markdown入力するとプレビューにHTMLで表示されている。' do
        assert_selector 'h1', text: 'h1'
      end
    end

    test 'description of the daily report is previewed when copied' do
      visit_with_auth report_path(reports(:report1)), 'komagata'
      click_link 'コピー'
      within('form[name=report]') do
        fill_in('report[description]', with: "Markdown入力するとプレビューにHTMLで表示されている。\n # h1")
      end
      assert_selector '.js-preview.markdown-form__preview', text: 'Markdown入力するとプレビューにHTMLで表示されている。' do
        assert_selector 'h1', text: 'h1'
      end
    end

    test 'automatically resizes textarea of a new report' do
      visit_with_auth '/reports/new', 'komagata'
      fill_in('report[description]', with: 'test')
      height = find('#report_description').style('height')['height'][/\d+/].to_i

      fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22")
      after_height = find('#report_description').style('height')['height'][/\d+/].to_i

      assert height < after_height
    end

    test 'automatically resizes textarea of an edit report' do
      visit_with_auth report_path(reports(:report1)), 'komagata'
      click_link '内容修正'

      height = find('#report_description').style('height')['height'][/\d+/].to_i

      fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22")
      after_height = find('#report_description').style('height')['height'][/\d+/].to_i

      assert height < after_height
    end

    test 'should ignore invalid class name to prevent XSS attack' do
      visit_with_auth '/reports/new', 'komagata'
      within('form[name=report]') do
        fill_in('report[title]', with: 'test title')
        fill_in('report[description]', with: <<~TEXT)
          :::message "></div><a href="javascript:alert('XSS');">クリックしてね</a><div class="
          ここにメッセージが入ります。
          :::
        TEXT
        fill_in('report[reported_on]', with: Time.current)
        check '学習時間は無し', allow_label_click: true
      end
      click_button '提出'
      assert_text 'ここにメッセージが入ります。'
      assert_no_text 'クリックしてね'
    end

    test 'should accept valid class name' do
      visit_with_auth '/reports/new', 'komagata'
      within('form[name=report]') do
        fill_in('report[title]', with: 'test title')
        fill_in('report[description]', with: <<~TEXT)
          :::message success
          ここにメッセージが入ります。
          :::
        TEXT
        fill_in('report[reported_on]', with: Time.current)
        check '学習時間は無し', allow_label_click: true
      end
      click_button '提出'
      within('.success') do
        assert_text 'ここにメッセージが入ります。'
      end
    end
  end
end
