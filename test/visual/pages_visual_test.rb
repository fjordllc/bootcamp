# frozen_string_literal: true

require 'application_visual_test_case'

# Visual regression coverage for a curated set of representative screens.
#
# Start thin: these pages exercise the shared building blocks that the CSS
# refactor touched (buttons, cards, forms, page/report layout, LP). Add more
# pages once the baseline is stable in CI.
#
# Run just these:  bin/rails test test/visual/pages_visual_test.rb
class PagesVisualTest < ApplicationVisualTestCase
  test 'dashboard' do
    visit_with_auth '/', 'hatsuno'
    assert_selector '.page-body'
    capture('dashboard')
  end

  test 'report show' do
    report = reports(:report1)
    visit_with_auth "/reports/#{report.id}", 'komagata'
    assert_selector '.page-content'
    capture('report_show')
  end

  test 'report form' do
    visit_with_auth '/reports/new', 'komagata'
    assert_selector 'form'
    capture('report_form')
  end

  test 'users index' do
    visit_with_auth '/users', 'komagata'
    assert_selector '.users-item', minimum: 1
    capture('users_index')
  end

  test 'user profile' do
    user = users(:hatsuno)
    visit_with_auth "/users/#{user.id}", 'komagata'
    assert_selector '.user-profile, .page-content'
    capture('user_profile')
  end

  test 'lp practices' do
    visit '/practices'
    assert_selector '.lp-header'
    capture('lp_practices')
  end
end
