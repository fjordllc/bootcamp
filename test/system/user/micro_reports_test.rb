# frozen_string_literal: true

require 'application_system_test_case'

class MicroReportsTest < ApplicationSystemTestCase
  test 'show all micro reports of the target user' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    assert_text '分報（2）'
    assert_text '今日も頑張るぞ！'
    assert_text '今日も頑張った。'
  end

  test 'form not found in other user microo reports page' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    assert has_no_field?(id: 'js-micro-report-textarea')
    assert_no_button '投稿'
  end

  test 'form found in current user micro reports page' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert has_field?(id: 'js-micro-report-textarea')
    assert_button '投稿'
  end

  test 'form has micro report tab and preview tab' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    within('.micro-report-form-tabs') do
      assert_text '分報'
      assert_text 'プレビュー'
    end
  end

  test 'create micro report' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert_text '分報（0）'
    assert_text '分報の投稿はまだありません。'
    fill_in('micro_report[content]', with: '初めての分報です。')
    click_button '投稿'
    assert_text '分報（1）'
    assert_text '初めての分報です。'
    assert_text '分報（1）'
  end

  test 'can not create micro report with empty content' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    click_button '投稿'
    assert_text '分報（0）'
    assert_text '分報の投稿に失敗しました。'
  end

  test 'content is interpreted as markdown in preview tab' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    fill_in('micro_report[content]', with: "Markdown入力するとプレビューにHTMLで表示されている。\n # h1")
    within('.micro-report-form-tabs') do
      click_on 'プレビュー'
    end
    assert_selector '.micro-report-form__preview', text: 'Markdown入力するとプレビューにHTMLで表示されている。' do
      assert_selector 'h1', text: 'h1'
    end
  end
end
