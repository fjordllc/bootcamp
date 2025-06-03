# frozen_string_literal: true

require 'application_system_test_case'

class ReportLearningTimeTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'create and update learning times in a report' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    assert_difference 'LearningTime.count', 1 do
      click_button '提出'
    end

    click_link '内容修正'
    click_link '学習時間追加'

    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('09')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('10')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')

    assert_difference 'LearningTime.count', 1 do
      click_button '内容変更'
    end
  end

  test 'issue #360 duplicate' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '不具合再現の結合テストコード'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('08')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('09')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')

    click_link '学習時間追加'
    all('.learning-time')[2].all('.learning-time__started-at select')[0].select('19')
    all('.learning-time')[2].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[2].all('.learning-time__finished-at select')[0].select('20')
    all('.learning-time')[2].all('.learning-time__finished-at select')[1].select('15')

    click_button '提出'

    assert_text '2時間45分'
    assert_text '07:30 〜 08:30'
    assert_text '08:30 〜 09:30'
    assert_text '19:30 〜 20:15'
  end

  test 'register learning_times 2h' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報 成功'
    fill_in 'report_description', with: '不具合再現の結合テストコード'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('08')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('09')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'

    assert_text "2時間\n"
    assert_text '07:30 〜 08:30'
    assert_text '08:30 〜 09:30'
  end

  test 'register learning_times 1h40m' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報 成功'
    fill_in 'report_description', with: '不具合再現の結合テストコード'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('19')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('20')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('15')

    click_button '提出'

    assert_text "1時間45分\n"
    assert_text '07:30 〜 08:30'
    assert_text '19:30 〜 20:15'
  end

  test 'register learning_time 45m' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報 成功'
    fill_in 'report_description', with: '不具合再現の結合テストコード'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('19')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('20')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('15')

    click_button '提出'

    assert_text "45分\n"
    assert_text '19:30 〜 20:15'
  end

  test 'canonicalize learning times when create and update a report' do
    visit_with_auth '/reports/new', 'komagata'

    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '完了日時 - 開始日時 < 0のパターン'
    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('23')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('00')

    click_button '提出'

    within '.learning-times__total-time' do
      assert_text '1時間', exact: true
    end
    assert_text '23:00 〜 (翌日)00:00'

    click_link '内容修正'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('23')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('23')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('45')

    click_button '内容変更'

    within '.learning-times__total-time' do
      assert_text '0時間45分', exact: true
    end
    assert_text '23:00 〜 23:45'
  end

  test 'register learning_times 4h' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '複数時間登録のパターン'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('22')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('00')

    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('00')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('02')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'

    assert_text "4時間\n"
    assert_text '22:00 〜 (翌日)00:00'
    assert_text '00:30 〜 02:30'
  end

  test 'learning times when carrying over next month' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '学習時間が月を跨いでいるパターン'
    fill_in 'report_reported_on', with: Date.new(2024, 1, 31)

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('22')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('00')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('00')

    click_button '提出'

    assert_text "2時間\n"
    assert_text '22:00 〜 (翌日)00:00'
  end

  test 'learning times order' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '学習時間の順番'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('19')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('20')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('15')

    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    assert_selector('ul.learning-times__items li.learning-times__item:nth-child(1)', text: '07:30 〜 08:30')
    assert_selector('ul.learning-times__items li.learning-times__item:nth-child(2)', text: '19:30 〜 20:15')
  end

  test 'add learning times the next day' do
    visit_with_auth '/reports/new', 'komagata'
    fill_in 'report_title', with: 'テスト日報'
    fill_in 'report_description', with: '学習時間の順番'

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('19')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('20')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('15')
    click_button '提出'

    travel 1.day

    click_link '内容修正'
    click_link '学習時間追加'
    all('.learning-time')[1].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[1].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[1].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[1].all('.learning-time__finished-at select')[1].select('30')
    click_button '内容変更'

    assert_selector('ul.learning-times__items li.learning-times__item:nth-child(1)', text: '07:30 〜 08:30')
    assert_selector('ul.learning-times__items li.learning-times__item:nth-child(2)', text: '19:30 〜 20:15')
  end
end
