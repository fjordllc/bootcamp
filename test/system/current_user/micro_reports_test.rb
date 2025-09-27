# frozen_string_literal: true

require 'application_system_test_case'

class  CurrentUser::MicroReportsTest < ApplicationSystemTestCase
  test 'show current_user micro reports page' do
    visit_with_auth '/current_user/micro_reports', 'kimura'
    assert_equal '自分の分報一覧 | FBC', title
  end

  test 'show empty message when no micro reports' do
    assert_equal 0, users(:kimura).micro_reports.count
    visit_with_auth '/current_user/micro_reports', 'kimura'
    assert_text '分報の投稿はまだありません。'
  end
end
