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
      assert_selector 'h2.page-header__title', text: '日報編集', wait: 5
    else
      assert_selector 'h1.page-content-header__title', text: title
    end

    report_match_id = current_path.match(%r{^/reports/(\d+)(/edit|)$})
    assert report_match_id, "Unexpected path after creating report: #{current_path}"
    report_match_id[1].to_i
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
end
