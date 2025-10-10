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

  def create_report_as(author_name, title, description, wip)
    visit_with_auth new_report_path, author_name
    assert_selector 'h2.page-header__title', text: '日報作成'
    id = create_report(title, description, wip)
    logout
    id
  end

    edit_report(title, description)

    if wip
      click_button 'WIP'
      return
    end

  def update_report_as(id, author_name, title, description, save_as_wip)
    visit_with_auth edit_report_path(id), author_name
    assert_selector 'h2.page-header__title', text: '日報編集'
    update_report(id, title, description, save_as_wip)
    logout
  end

  def edit_report(title, description)
    fill_in('report[title]', with: title)
    fill_in('report[description]', with: description)
  end

  def notification_selector
    'span.card-list-item-title__link-label'
  end
end
