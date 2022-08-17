# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'create report as WIP' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end
    click_button 'WIP'
    assert_text '日報をWIPとして保存しました。'
  end

  test 'create a report' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)
    end

    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_text Time.current.strftime('%Y年%m月%d日')
    assert_text 'Watch中'
  end

  test 'create a report without learning time' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
      fill_in('report[reported_on]', with: Time.current)

      first('.learning-time').all('.learning-time__started-at select')[0].select('07')
      first('.learning-time').all('.learning-time__started-at select')[1].select('30')
      first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
      first('.learning-time').all('.learning-time__finished-at select')[1].select('30')

      check '学習時間は無し', allow_label_click: true
    end

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_text '学習時間無し'
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

  test 'equal practices order in practices and new report' do
    visit_with_auth '/reports/new', 'komagata'
    first('.choices__inner').click
    report_practices = page.all('.choices__item--choice').map(&:text)
    current_user = users(:komagata)
    category_ids = current_user.course.category_ids
    assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).count
    assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
    assert_match(/sslの基礎を理解する/, all('.choices__item--choice').last.text)
  end

  test 'equal practices order in practices and edit report' do
    visit_with_auth "/reports/#{reports(:report1).id}/edit", 'komagata'
    first('.choices__inner').click
    report_practices = page.all('.choices__item--choice').map(&:text)
    current_user = users(:komagata)
    category_ids = current_user.course.category_ids
    assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).count
    assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
    assert_match(/sslの基礎を理解する/, all('.choices__item--choice').last.text)
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
    assert_text '23:00 〜 00:00'

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
    assert_text '22:00 〜 00:00'
    assert_text '00:30 〜 02:30'
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

  test 'reports can be copied' do
    visit_with_auth report_path(users(:komagata).reports.first), 'komagata'
    travel 5.days do
      find('#copy').click
      assert_equal find('#report_reported_on').value, Date.current.strftime('%Y-%m-%d')
    end
  end

  test 'previous report' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'komagata'
    click_link '前の日報'
    assert_equal "/reports/#{reports(:report1).id}", current_path
  end

  test 'next report' do
    visit_with_auth "/reports/#{reports(:report2).id}", 'komagata'
    click_link '次の日報'
    assert_equal "/reports/#{reports(:report3).id}", current_path
  end

  test 'report has a comment form ' do
    visit_with_auth "/reports/#{reports(:report1).id}", 'mentormentaro'
    assert_selector '.thread-comment-form'
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

  test 'change report status to wip' do
    report = reports(:report15)
    visit_with_auth "/reports/#{report.id}", 'hajime'

    click_link '内容修正'
    assert_text 'この日報はすでに提出済みです。'
    click_button 'WIP'
    assert_no_text 'この日報はすでに提出済みです。'
  end

  test 'reports are ordered in descending of reported_on' do
    visit_with_auth reports_path, 'kimura'
    precede = reports(:report24).title
    succeed = reports(:report23).title
    within '.card-list__items' do
      assert page.text.index(precede) < page.text.index(succeed)
    end
  end

  test 'reports are ordered in descending of created_at if reported_on is same' do
    visit_with_auth reports_path, 'kimura'
    precede = reports(:report18).title
    succeed = reports(:report17).title

    within '.card-list__items' do
      assert page.text.index(precede) < page.text.index(succeed)
    end
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

  test 'update report without learning time' do
    visit_with_auth edit_report_path(reports(:report1)), 'komagata'
    check '学習時間は無し', allow_label_click: true
    click_button '内容変更'
    assert_text '学習時間無し'
  end

  test 'select box shows the practices that belong to a user course' do
    visit_with_auth reports_path, 'kimura'
    find('.choices__inner').click
    page_practices = page.all('.choices__item--choice').map(&:text).size
    course_practices = users(:kimura).course.practices.size + 1
    assert_equal page_practices, course_practices
  end

  test 'show number of comments' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    within(:css, '.is-emphasized') do
      assert_text '2'
    end
  end

  test 'cannot post a new report with future date' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: '学習日が未来日では日報を作成できない')
      fill_in('report[description]', with: 'エラーになる')
      fill_in('report[reported_on]', with: Date.current.next_day)
    end
    click_button '提出'
    assert_text '学習日は今日以前の日付にしてください'
  end

  test 'display list of submission when mentor is access' do
    visit_with_auth report_path(reports(:report5)), 'komagata'
    assert_text '提出物'
    find('#side-tabs-nav-3').click
    assert_text 'Terminalの基礎を覚える'
    assert_text 'PC性能の見方を知る'
  end

  test 'not display list of submission when mentor is access' do
    visit_with_auth report_path(reports(:report5)), 'kimura'
    assert_no_selector '#side-tabs-content-3'
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

    fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\7\n8\n9\n10\n11\n12\n13\n14\n15")
    after_height = find('#report_description').style('height')['height'][/\d+/].to_i

    assert height < after_height
  end

  test 'automatically resizes textarea of an edit report' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    click_link '内容修正'

    height = find('#report_description').style('height')['height'][/\d+/].to_i

    fill_in('report[description]', with: "\n1\n2\n3\n4\n5\n6\7\n8\n9\n10\n11\n12\n13\n14\n15")
    after_height = find('#report_description').style('height')['height'][/\d+/].to_i

    assert height < after_height
  end

  test 'display report interval for mentor while undoing wip' do
    visit_with_auth report_path(reports(:report32)), 'komagata'
    assert_selector '.a-page-notice.is-only-mentor.is-danger', text: '10日ぶりの日報です'

    visit_with_auth report_path(reports(:report33)), 'kananashi'
    click_link '内容修正'
    click_button '提出'

    visit_with_auth report_path(reports(:report32)), 'komagata'
    assert_no_selector '.a-page-notice.is-only-mentor.is-danger', text: '9日ぶりの日報です'
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
    assert_text '100日目の日報を提出しました。'
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

  test 'mentors can see reports page if products published_at is nil' do
    visit_with_auth '/reports/unchecked', 'mentormentaro'
    click_link 'テストのnippou'
    assert_text '2022年04月01日 の日報'
    assert_text '今日は1時間学習しました。'
  end

  test 'open new report with a past date' do
    visit_with_auth '/reports/new?reported_on=2022-1-1', 'komagata'
    assert_equal '2022-01-01', find('#report_reported_on').value
  end

  test 'hide user icon from recent reports in report show' do
    visit_with_auth report_path(reports(:report1)), 'komagata'
    assert_no_selector('.card-list-item__user')
  end

  test 'display user icon in reports' do
    visit_with_auth reports_path, 'komagata'
    assert_selector('.card-list-item__user')
  end
end
