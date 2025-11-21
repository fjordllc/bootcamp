# frozen_string_literal: true

module ReportHelper
  def create_report(title, description, save_as_wip:)
    visit new_report_path
    assert_selector 'h2.page-header__title', text: '日報作成', wait: 20

    edit_report(title, description)

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    if save_as_wip
      click_button('WIP')
      assert_selector 'h2.page-header__title', text: '日報編集'
    else
      click_button('提出')
      assert_selector 'h1.page-content-header__title', text: title
    end

    # 作成した日報のpathからidを返す
    path_match = current_path.match(%r{^/reports/(\d+)(/edit)?$})
    assert path_match, "Unexpected path after creating report: #{current_path}"
    path_match[1].to_i
  end

  def create_report_as(author_login_name, title, description, save_as_wip:)
    as_user(author_login_name) do
      create_report(title, description, save_as_wip:)
    end
  end

  def update_report(report_id, title, description, save_as_wip:)
    visit edit_report_path(report_id)
    assert_selector 'h2.page-header__title', text: '日報編集'

    edit_report(title, description)

    if save_as_wip
      click_button 'WIP'
      assert_selector 'h2.page-header__title', text: '日報編集'
    elsif page.has_button?('提出')
      click_button '提出'
      assert_selector 'h1.page-content-header__title', text: title
    else
      click_button '内容変更'
      assert_selector 'h1.page-content-header__title', text: title
    end
  end

  def update_report_as_author(report_id, title, description, save_as_wip:)
    as_user(Report.find(report_id).user.login_name) do
      update_report(report_id, title, description, save_as_wip:)
    end
  end

  def wait_for_report_form
    assert_selector 'input[name="report[title]"]:not([disabled])', wait: 20
  end

  def edit_report(title, description)
    wait_for_report_form
    fill_in('report[title]', with: title)
    fill_in('report[description]', with: description)
  end

  def notification_selector
    'span.card-list-item-title__link-label'
  end

  def delete_all_reports(user_login_name)
    user = User.find_by(login_name: user_login_name)
    user.reports.delete_all
  end

  def as_user(login_name)
    visit_with_auth root_path, login_name
    assert_selector 'h2.page-header__title', text: 'ダッシュボード'
    yield
  ensure
    logout
  end
end
