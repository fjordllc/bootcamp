# frozen_string_literal: true

module ReportHelper
  def create_report(title, description, wip)
    visit new_report_path
    assert_selector 'h2.page-header__title', text: '日報作成'

    edit_report(title, description)

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    click_button(wip ? 'WIP' : '提出')

    if wip
      assert_selector 'h2.page-header__title', text: '日報編集'
    else
      assert_selector 'h1.page-content-header__title', text: title
    end

    # 作成した日報のpathからidを返す
    path_match = current_path.match(%r{^/reports/(\d+)(/edit)?$})
    assert path_match, "Unexpected path after creating report: #{current_path}"
    path_match[1].to_i
  end

  def update_report(id, title, description, wip)
    visit edit_report_path(id)

    edit_report(title, description)

    if wip
      click_button 'WIP'
      return
    end

    # click_buttonでは正規表現使えない
    click_button(page.has_button?('提出') ? '提出' : '内容変更')
  end

  def edit_report(title, description)
    fill_in('report[title]', with: title)
    fill_in('report[description]', with: description)
  end

  def create_report_data_with_learning_times(user:, on:, wip: false, no_learn: false, durations: [[9, 12]])
    report = Report.new(user:, title: "test #{on}", emotion: 2, description: 'desc', reported_on: on, wip:, no_learn:)
    unless no_learn
      durations.each do |(s, e)|
        report.learning_times << LearningTime.new(report:, started_at: Time.zone.parse("#{on} #{format('%02d:00:00', s)}"),
                                                  finished_at: Time.zone.parse("#{on} #{format('%02d:00:00', e)}"))
      end
    end
    report.save!
    report
  end
end
