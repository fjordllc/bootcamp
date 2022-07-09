# frozen_string_literal: true

require 'application_system_test_case'

class MarkdownLinkTest < ApplicationSystemTestCase
  test 'external link on another tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'external link test')
      fill_in('report[description]', with: 'http://www.google.co.jp')
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find('a', text: 'http://www.google.co.jp')[:href], 'http://www.google.co.jp/'
    assert_equal find('a', text: 'http://www.google.co.jp')[:target], '_blank'
  end

  test 'internal link on same tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'internal link test')
      fill_in('report[description]', with: (current_host + ":#{Capybara.current_session.server.port}"))
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find('a', text: current_host)[:href], (current_host + ":#{Capybara.current_session.server.port}/")
    assert_not_equal find('a', text: current_host)[:target], '_blank'
  end

  test 'relative link on same tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'relative link test')
      fill_in('report[description]', with: '[relative_link](/reports)')
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find('a', text: 'relative_link')[:href], (current_host + ":#{Capybara.current_session.server.port}/reports")
    assert_not_equal find('a', text: 'relative_link')[:target], '_blank'
  end

  test 'anchor link on same tab' do
    visit_with_auth 'reports/new', 'kimura'
    within('form[name=report]') do
      fill_in('report[title]', with: 'anchor link test')
      fill_in('report[description]', with: "[anchor_link](#anchortext)\n## <a id='anchortext' />anchor")
    end
    first('.learning-time').all('.learning-time__started-at select')[0].select('07')
    first('.learning-time').all('.learning-time__started-at select')[1].select('30')
    first('.learning-time').all('.learning-time__finished-at select')[0].select('08')
    first('.learning-time').all('.learning-time__finished-at select')[1].select('30')
    click_button '提出'
    assert_equal find('a', text: 'anchor_link')[:href], "#{current_url}#anchortext"
    assert_not_equal find('a', text: 'anchor_link')[:target], '_blank'
  end
end
