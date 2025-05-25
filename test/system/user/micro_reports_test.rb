# frozen_string_literal: true

require 'application_system_test_case'

class MicroReportsTest < ApplicationSystemTestCase
  test 'show all micro reports of the target user' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    assert_text '分報 （3）'
    assert_text '最初の分報'
    assert_text '2つ目の分報'
    assert_text '最初の分報'
  end

  test 'micro reports are ordered by created_at asc' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    within('.micro-reports-posts') do
      assert_selector '.thread-comment', count: 3
      within first('.thread-comment') do
        assert_text '最初の分報'
      end

      within all('.thread-comment').last do
        assert_text '最新の分報'
      end
    end
  end

  test 'form not found in other user microo reports page' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    assert has_no_field?(id: 'js-micro-report-textarea')
    assert_no_button '投稿'
  end

  test 'form found in current user micro reports page' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert has_field?(id: 'js-micro-report-textarea')
    assert_button '投稿', disabled: true
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
    assert_text '分報 （0）'
    assert_text '分報の投稿はまだありません。'
    fill_in('micro_report[content]', with: '初めての分報です。')
    click_button '投稿'
    assert_text '分報 （1）'
    assert_text '初めての分報です。'
    assert_text '分報 （1）'
  end

  test 'submit button is disabled and enabled based on textarea content' do
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'

    assert_button '投稿', disabled: true

    fill_in('micro_report[content]', with: '投稿ボタンを有効化')
    assert_button '投稿', disabled: false

    fill_in('micro_report[content]', with: '')
    assert_button '投稿', disabled: true
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

  test 'show pagination when over 26 micro reports exist' do
    users(:hatsuno).micro_reports.create!(Array.new(25) { |i| { content: "分報#{i + 1}" } })
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert_no_selector '.pagination__items'
    assert_selector '.thread-comment', count: 25

    users(:hatsuno).micro_reports.create!(content: '分報26')
    visit current_path # 作成した分報を反映させるためにページをリロード
    assert_selector '.pagination__items', count: 2
    assert_selector '.thread-comment', count: 25
    within first('.pagination__items') do
      click_link '2'
    end
    assert_selector '.thread-comment', count: 1
  end

  test 'redirect to latest micro report page when over 26 micro reports exist' do
    users(:hatsuno).micro_reports.create!(Array.new(25) { |i| { content: "分報#{i + 1}" } })
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert_no_selector '.pagination__items'
    assert_selector '.thread-comment', count: 25

    # 26件目投稿時に2ページ目に遷移するか
    fill_in('micro_report[content]', with: '分報26')
    click_button '投稿'
    assert_selector '.pagination__item.is-active', text: '2'

    # タブから分報一覧に遷移するときに2ページ目に遷移するか
    click_on '分報 （26）'
    assert_selector '.pagination__item.is-active', text: '2'
  end
end
