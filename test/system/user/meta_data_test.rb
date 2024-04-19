# frozen_string_literal: true

require 'application_system_test_case'

class User::MetaDataTest < ApplicationSystemTestCase
  test 'show progress percentage and click to check the number of completions' do
    user = users(:harikirio)
    user.completed_practices << practices(:practice5)
    user.completed_practices << practices(:practice61)
    visit_with_auth "/users/#{users(:harikirio).id}", 'harikirio'
    assert_text '1%'
    find('.completed-practices-progress__percentage').click
    assert_text '修了: 2 （必須: 1/51）'
  end
end
