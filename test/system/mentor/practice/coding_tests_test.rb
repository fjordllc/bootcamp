# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::Practices::CodingTestsTest < ApplicationSystemTestCase
  test 'coding tests can be reordered' do
    visit_with_auth "/mentor/practices/#{practices(:practice1).id}/coding_tests", 'komagata'
    assert_equal coding_tests(:coding_test1).title, all('td.admin-table__item-value')[0].text
    assert_equal coding_tests(:coding_test2).title, all('td.admin-table__item-value')[2].text
    source = all('.js-grab')[0]
    target = all('.js-grab')[1]
    source.drag_to(target)

    visit_with_auth "/mentor/practices/#{practices(:practice1).id}/coding_tests", 'komagata'
    assert_equal coding_tests(:coding_test2).title, all('td.admin-table__item-value')[0].text
    assert_equal coding_tests(:coding_test1).title, all('td.admin-table__item-value')[2].text
  end
end
