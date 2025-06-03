# frozen_string_literal: true

require 'application_system_test_case'

class ReportUiFeaturesTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
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

    fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22")
    after_height = find('#report_description').style('height')['height'][/\d+/].to_i

    assert height < after_height
  end

  test 'automatically resizes textarea of an edit report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    click_link '内容修正'

    height = find('#report_description').style('height')['height'][/\d+/].to_i

    fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22")
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

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth '/reports/new', 'kensyu'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end
end
