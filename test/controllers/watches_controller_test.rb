# frozen_string_literal: true

require 'test_helper'

class WatchesControllerTest < ActionDispatch::IntegrationTest
  test 'create creates a watch and replaces the watch toggle with a Turbo Stream' do
    sign_in(:hajime)
    report = reports(:report1)
    params = {
      watchable_id: report.id,
      watchable_type: Report.name
    }

    assert_difference -> { Watch.count }, 1 do
      post watches_path, params:, as: :turbo_stream
    end

    assert_turbo_stream(
      action: 'replace',
      target: dom_id(report, :watch_toggle)
    ) do
      assert_select 'template .watch-toggle.is-active', text: 'Watch中'
    end
  end

  test 'create does not allow a duplicate watch' do
    sign_in(:hajime)
    report = reports(:report1)
    params = {
      watchable_id: report.id,
      watchable_type: Report.name
    }
    Watch.create!(user: users(:hajime), watchable: report)

    assert_no_difference -> { Watch.count } do
      post watches_path, params:, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test 'create returns unprocessable entity when the resource is not watchable' do
    sign_in(:hajime)
    user = users(:komagata)
    params = {
      watchable_id: user.id,
      watchable_type: User.name
    }

    assert_no_difference -> { Watch.count } do
      post watches_path, params:, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test 'destroy destroys a watch and replaces the watch toggle with a Turbo Stream' do
    sign_in(:hajime)
    report = reports(:report1)
    watch = Watch.create!(user: users(:hajime), watchable: report)

    assert_difference -> { Watch.count }, -1 do
      delete watch_path(watch), as: :turbo_stream
    end

    assert_turbo_stream(
      action: 'replace',
      target: dom_id(report, :watch_toggle)
    ) do
      assert_select 'template .watch-toggle.is-inactive', text: 'Watch'
    end
  end

  test 'destroy returns no content for an HTML request' do
    sign_in(:hajime)
    watch = Watch.create!(
      user: users(:hajime),
      watchable: reports(:report1)
    )

    assert_difference -> { Watch.count }, -1 do
      delete watch_path(watch)
    end

    assert_response :no_content
  end

  test "destroy does not destroy another user's watch" do
    sign_in(:hajime)
    watch = Watch.create!(user: users(:komagata), watchable: reports(:report1))

    assert_no_difference -> { Watch.count } do
      delete watch_path(watch), as: :turbo_stream
    end

    assert_response :not_found
  end
end
