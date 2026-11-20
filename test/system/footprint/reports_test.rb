# frozen_string_literal: true

require 'application_system_test_case'

class Footprint::ReportsTest < ApplicationSystemTestCase
  setup do
    @report = reports(:report1)
  end

  test 'should not footpoint with my own report' do
    visit_with_auth report_path(@report), 'komagata'
    assert_no_css '.a-user-icon.is-komagata'
  end

  test 'click on the link to view the rest of footprints' do
    user_data = User.unhibernated.unretired.last(11)
    user_data.map do |user|
      Footprint.create(
        user_id: user.id,
        footprintable_id: @report.id,
        footprintable_type: 'Report'
      )
    end

    visit_with_auth report_path(@report), 'komagata'
    assert_text 'その他1人'

    find('.user-icons__more').click
    assert_no_css '.user-icons__more'
  end
end
