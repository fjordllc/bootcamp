# frozen_string_literal: true

require 'browserless_system_test_case'

class Footprint::ReportsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @report = reports(:report1)
  end

  test 'should be create footprint in /reports/:id' do
    visit_with_auth report_path(@report), 'sotugyou'
    assert_css '.a-user-icon.is-sotugyou'
  end

  test 'show link if there are more than ten footprints' do
    user_data = User.unhibernated.unretired.last(10)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @report.id,
        footprintable_type: 'Report'
      )
    end

    visit_with_auth report_path(@report), 'machida'
    assert_css '.user-icons__more'
  end

  test 'has no link if there are ten or less footprints' do
    user_data = User.unhibernated.unretired.last(9)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @report.id,
        footprintable_type: 'Report'
      )
    end

    visit_with_auth report_path(@report), 'machida'
    assert_no_css '.user-icons__more'
  end
end
