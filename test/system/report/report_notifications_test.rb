# frozen_string_literal: true

require 'application_system_test_case'

class ReportNotificationsTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  # 画面上では更新の完了がわからないため、やむを得ずsleepする
  # 注意）安易に使用しないこと!! https://bootcamp.fjord.jp/pages/use-assert-text-instead-of-wait-for-vuejs
  def wait_for_watch_change
    sleep 1
  end

  test 'unwatch' do
    visit_with_auth report_path(reports(:report1)), 'kimura'
    assert_difference('Watch.count', -1) do
      find('div.a-watch-button', text: 'Watch中').click
      wait_for_watch_change
    end
  end

  test 'click unwatch' do
    visit_with_auth report_path(reports(:report1)), 'kimura'
    assert_difference('Watch.count', -1) do
      find('div.a-watch-button', text: 'Watch中').click
      wait_for_watch_change
    end
  end

  test 'notify to chat after create a report' do
    visit_with_auth '/reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

    mock_log = []
    stub_info = proc { |i| mock_log << i }

    Rails.logger.stub(:info, stub_info) do
      click_button '提出'
    end

    assert_text '日報を保存しました。'
    assert_text Time.current.strftime('%Y年%m月%d日')
    assert_text 'Watch中'
    assert_match 'Message to Discord.', mock_log.to_s
  end

  test 'celebrating one hundred reports' do
    user = users(:nippounashi)
    99.times do |i|
      Report.create!(
        user_id: user.id,
        title: "日報タイトル #{i + 1}",
        reported_on: (99 - i).days.ago,
        emotion: 'happy',
        no_learn: true,
        wip: false,
        description: "日報の内容 #{i + 1}"
      )
    end
    visit_with_auth '/reports/new', 'nippounashi'
    within('form[name=report]') do
      fill_in('report[title]', with: '100回目の日報')
      fill_in('report[description]', with: '日報の内容 100')
      fill_in('report[reported_on]', with: Time.current)

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_text 'おめでとう！'
    assert_text '100回目の日報を提出しました。'
  end

  test 'adviser watches trainee report when trainee create report' do
    visit_with_auth '/reports/new', 'kensyu'
    within('form[name=report]') do
      fill_in('report[title]', with: '研修生の日報')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end
    within('.learning-time__started-at') do
      select '07'
      select '30'
    end
    within('.learning-time__finished-at') do
      select '08'
      select '30'
    end

    click_button '提出'
    assert_text '日報を保存しました。'

    visit_with_auth '/current_user/watches', 'senpai'

    assert_text '研修生の日報'
  end
end
