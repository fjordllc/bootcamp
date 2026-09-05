# frozen_string_literal: true

require 'test_helper'

class Watches::RefreshesControllerTest < ActionDispatch::IntegrationTest
  test 'show replaces the watch toggle with a watched state' do
    sign_in(:hajime)
    report = reports(:report1)
    Watch.create!(user: users(:hajime), watchable: report)

    get watches_refresh_path,
        params: {
          watchable_id: report.id,
          watchable_type: Report.name
        },
        as: :turbo_stream

    assert_turbo_stream(
      action: 'replace',
      target: dom_id(report, :watch_toggle)
    ) do
      assert_select 'template .watch-toggle.is-active', text: 'Watch中'
    end
  end

  test 'show replaces the watch toggle with an unwatched state' do
    sign_in(:hajime)
    report = reports(:report1)

    get watches_refresh_path,
        params: {
          watchable_id: report.id,
          watchable_type: Report.name
        },
        as: :turbo_stream

    assert_turbo_stream(
      action: 'replace',
      target: dom_id(report, :watch_toggle)
    ) do
      assert_select 'template .watch-toggle.is-inactive', text: 'Watch'
    end
  end

  test 'show returns unprocessable entity when the resource is
    not watchable' do
    sign_in(:hajime)
    user = users(:komagata)

    get watches_refresh_path,
        params: {
          watchable_id: user.id,
          watchable_type: User.name
        },
        as: :turbo_stream

    assert_response :unprocessable_entity
  end
end
