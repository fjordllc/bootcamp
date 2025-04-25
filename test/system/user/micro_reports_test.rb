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
    within('.micro-reports__items') do
      assert_selector '.micro-report', count: 3
      within first('.micro-report') do
        assert_text '最初の分報'
      end

      within all('.micro-report').last do
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
    assert_selector '.micro-report', count: 25

    users(:hatsuno).micro_reports.create!(content: '分報26')
    visit current_path # 作成した分報を反映させるためにページをリロード
    assert_selector '.pagination__items', count: 2
    assert_selector '.micro-report', count: 25
    within first('.pagination__items') do
      click_link '2'
    end
    assert_selector '.micro-report', count: 1
  end

  test 'redirect to latest micro report page when over 26 micro reports exist' do
    users(:hatsuno).micro_reports.create!(Array.new(25) { |i| { content: "分報#{i + 1}" } })
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert_no_selector '.pagination__items'
    assert_selector '.micro-report', count: 25

    # 26件目投稿時に2ページ目に遷移するか
    fill_in('micro_report[content]', with: '分報26')
    click_button '投稿'
    assert_selector '.pagination__item.is-active', text: '2'

    # タブから分報一覧に遷移するときに2ページ目に遷移するか
    click_on '分報 （26）'
    assert_selector '.pagination__item.is-active', text: '2'
  end

  test 'only owner and admin can edit micro_reports' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'
    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_selector 'button', text: '内容修正'
      click_button '内容修正'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end

    visit_with_auth user_micro_reports_path(users(:hajime)), 'komagata'
    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_selector 'button', text: '内容修正'
      click_button '内容修正'
      assert_text 'コメント'
      assert_text 'プレビュー'
    end

    visit_with_auth user_micro_reports_path(users(:hajime)), 'mentormentaro'
    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_no_selector 'button', text: '内容修正'
    end
  end

  test 'only owner and admin can delete micro_reports' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_selector 'a', text: '削除する' }

    visit_with_auth user_micro_reports_path(users(:hajime)), 'komagata'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_selector 'a', text: '削除する' }

    visit_with_auth user_micro_reports_path(users(:hajime)), 'mentormentaro'
    within(".micro-report#micro_report_#{micro_report.id}") { assert_no_selector 'a', text: '削除する' }
  end

  test 'update micro_report through comment tab form' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'
    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_text '最初の分報'
      click_link_or_button '内容修正'
      fill_in('micro_report[content]', with: '初めての分報')
      click_link_or_button '保存する'
      assert_text '初めての分報'
    end
  end

  test 'delete micro_report' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'

    assert_text '最初の分報'
    within(".micro-report#micro_report_#{micro_report.id}") do
      click_link_or_button '削除する'
      page.accept_alert
    end

    assert_text '分報を削除しました。'
    assert_no_text '最初の分報'
  end

  test 'cancel updating micro_report through micro_report form' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'
    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_text '最初の分報'
      click_link_or_button '内容修正'
      fill_in('micro_report[content]', with: '初めての分報')
      click_link_or_button 'キャンセル'
      assert_text '最初の分報'
      assert_no_text '初めての分報'
    end
  end

  test 'micro_report content being edited is displayed in preview tab' do
    micro_report = micro_reports(:hajime_first_micro_report)
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hajime'

    within(".micro-report#micro_report_#{micro_report.id}") do
      assert_text '最初の分報'
      click_link_or_button '内容修正'
      fill_in('micro_report[content]', with: '初めての分報')

      find('.micro-report-form-tabs__item-link', text: 'プレビュー').click
      within("#js-comment-preview-#{micro_report.id}") do
        assert_text '初めての分報'
        assert_no_text '最初の分報'
      end
    end
  end

  test 'deleting micro_report redirect to original micro_report page when over 26 micro_reports exist' do
    users(:hatsuno).micro_reports.create!(Array.new(30) { |i| { content: "分報#{i + 1}" } })
    visit_with_auth user_micro_reports_path(users(:hatsuno)), 'hatsuno'
    assert_selector '.pagination__item.is-active', text: '1'

    within('.micro-report[data-micro_report_content="分報1"]') do
      click_link_or_button '削除する'
      page.accept_alert
    end

    assert_text '分報を削除しました。'
    assert_selector '.pagination__item.is-active', text: '1'
  end
end
