# frozen_string_literal: true

require 'application_system_test_case'

class ReportMentorFeaturesTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'display recently reports' do
    visit_with_auth report_path(reports(:report10)), 'mentormentaro'
    assert_selector 'img[alt="happy"]'
    assert_text '今日は頑張りました'
  end

  test 'display list of submission when mentor is access' do
    visit_with_auth report_path(reports(:report5)), 'komagata'
    assert_text '提出物'
    find('#side-tabs-nav-4').click
    assert_text 'Terminalの基礎を覚える'
    assert_text 'PC性能の見方を知る'
  end

  test 'not display list of submission when mentor is access' do
    visit_with_auth report_path(reports(:report5)), 'kimura'
    assert_no_selector '#side-tabs-content-3'
  end

  test 'show edit button when mentor is logged in and menter mode is on in report detail page' do
    visit_with_auth report_path(reports(:report1)), 'mentormentaro'
    assert_text '内容修正'
    find(:css, '#checkbox-mentor-mode').set(false)
    assert_no_text '内容修正'
  end

  test 'mentor can edit reports written by others' do
    visit_with_auth report_path(reports(:report1)), 'mentormentaro'
    click_link '内容修正'
    assert_no_text('変更された日報のタイトル')
    within('form[name=report]') do
      fill_in('report[title]', with: '変更された日報のタイトル')
    end
    click_button '内容変更'
    assert_text '日報を保存しました。'
    assert_text '変更された日報のタイトル'
  end

  test 'mentors can see reports page if products published_at is nil' do
    visit_with_auth '/reports/unchecked', 'mentormentaro'
    click_link 'テストのnippou'
    assert_text '今日は1時間学習しました。'
  end

  test 'display message to admin or mentor in report of retired user' do
    report = Report.create!(
      user: users(:yameo),
      title: '退会済みユーザーの日報',
      reported_on: '2022-01-03',
      emotion: 'happy',
      no_learn: true,
      wip: false,
      description: 'お世話になりました'
    )

    visit_with_auth report_path(report), 'komagata'
    assert_selector '.a-page-notice.is-muted.is-only-mentor', text: 'このユーザーは退会しています。'
  end
end
