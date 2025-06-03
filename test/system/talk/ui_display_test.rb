# frozen_string_literal: true

require 'application_system_test_case'

class TalkUiDisplayTest < ApplicationSystemTestCase
  test 'Displays a list of the 10 most recent reports' do
    user = users(:hajime)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    assert_text 'ユーザーの日報'
    page.find('#side-tabs-nav-2').click
    user.reports.first(10).each do |report|
      assert_text report.title
    end
  end

  test 'admin can see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    has_css?('page-tabs')
  end

  test 'non-admin user cannot see tabs on user talk page' do
    user = users(:kimura)
    visit_with_auth "/talks/#{user.talk.id}", 'kimura'
    has_no_css?('page-tabs')
  end

  test 'hide user icon from recent reports in talk show' do
    user = users(:hajime)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    page.find('#side-tabs-nav-2').click
    assert_no_selector('.card-list-item__user')
  end

  test 'talk show without recent reports' do
    user = users(:muryou)
    visit_with_auth "/talks/#{user.talk.id}", 'komagata'
    page.find('#side-tabs-nav-2').click
    assert_text '日報はまだありません。'
  end
end
