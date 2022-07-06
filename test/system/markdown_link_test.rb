# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownLinkTest < ApplicationSystemTestCase
  test 'external link on another tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'http://www.google.co.jp')
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find("a", text:"http://www.google.co.jp")[:href], "http://www.google.co.jp/"
    assert_equal find("a", text:"http://www.google.co.jp")[:target], "_blank"
  end

  test 'internal link on same tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'http://localhost:3000/reports')
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find("a", text:"http://localhost:3000/reports")[:href], "http://localhost:3000/reports"
    assert_not_equal find("a", text:"http://localhost:3000/reports")[:target], "_blank"
  end
end
