# frozen_string_literal: true

require 'application_system_test_case'

class ReportListTest < ApplicationSystemTestCase
  setup do
    @komagata = users(:komagata)
    @kimura = users(:kimura)
  end

  test 'equal practices order in practices and new report' do
    visit_with_auth '/reports/new', 'komagata'
    first('.choices__inner').click
    report_practices = page.all('.choices__item--choice').map(&:text)
    current_user = users(:komagata)
    category_ids = current_user.course.category_ids
    assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).distinct.count
    assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
    assert_match(/企業研究/, all('.choices__item--choice').last.text)
  end

  test 'equal practices order in practices and edit report' do
    visit_with_auth "/reports/#{reports(:report1).id}/edit", 'komagata'
    first('.choices__inner').click
    report_practices = page.all('.choices__item--choice').map(&:text)
    current_user = users(:komagata)
    category_ids = current_user.course.category_ids
    assert_equal report_practices.count, Practice.joins(:categories).merge(Category.where(id: category_ids)).distinct.count
    assert_match(/OS X Mountain Lionをクリーンインストールする/, first('.choices__item--choice').text)
    assert_match(/企業研究/, all('.choices__item--choice').last.text)
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

  test 'reports are ordered in descending of reported_on' do
    visit_with_auth reports_path, 'kimura'
    precede = reports(:report15).title
    succeed = reports(:report16).title
    assert_text '頑張りました'
    assert_text '頑張れませんでした'
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

  test 'select box shows the practices that belong to a user course' do
    visit_with_auth reports_path, 'kimura'
    find('.choices__inner').click
    page_practices = page.all('.choices__item--choice').map(&:text).size
    course_practices = users(:kimura).course.practices.size + 1
    assert_equal page_practices, course_practices
  end

  test 'user role class is displayed correctly in reports' do
    visit_with_auth '/reports/new', 'mentormentaro'
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

    visit_with_auth reports_path, 'kimura'
    within('.card-list-item__user', match: :first) do
      assert_selector('span.a-user-role.is-mentor')
    end
  end
end
