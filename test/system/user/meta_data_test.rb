# frozen_string_literal: true

require 'application_system_test_case'

class User::MetaDataTest < ApplicationSystemTestCase
  test 'show progress percentage and click to check the number of completions' do
    user = users(:harikirio)
    user.completed_practices = []
    user.completed_practices << practices(:practice61)
    user.completed_practices << practices(:practice62)
    user.completed_practices << practices(:practice63)
    visit_with_auth "/users/#{users(:harikirio).id}", 'harikirio'
    assert_text '1%'
    find('.completed-practices-progress__percentage').click
    assert_text '修了: 3 （必須: 1/52）'
  end
end
