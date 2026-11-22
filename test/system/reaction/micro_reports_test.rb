# frozen_string_literal: true

require 'application_system_test_case'

class Reaction::MicroReportsTest < ApplicationSystemTestCase
  # 取り消しなど、リアクションの操作の場合分けは test/system/reactions/report_test.rb で確かめる。
  # ここでは、この対象でリアクションの部品が働くことだけを確かめる。
  test 'reaction to micro report' do
    visit_with_auth user_micro_reports_path(users(:hajime)), 'hatsuno'
    first('.js-reaction-dropdown-toggle').click
    first(".js-reaction-dropdown li[data-reaction-kind='eyes']").click

    assert_text '👍1❤️1👀1'
  end
end
