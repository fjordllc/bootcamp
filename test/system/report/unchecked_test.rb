# frozen_string_literal: true

require 'application_system_test_case'

class Report::UncheckedTest < ApplicationSystemTestCase
  test 'show listing unchecked reports' do
    visit_with_auth '/reports/unchecked', 'komagata'
    assert_equal '未チェックの日報 | FBC', title
  end

  test 'display a message when there are no unchecked reports' do
    Report.unchecked.destroy_all

    visit_with_auth '/reports/unchecked', 'komagata'
    assert_text '未チェックの日報はありません'
  end

  test 'non-staff user can not see listing unchecked reports' do
    visit_with_auth '/reports/unchecked', 'hatsuno'
    assert_text '管理者・アドバイザー・メンターとしてログインしてください'
  end

  test 'mentor can see a button to open all unchecked reports' do
    visit_with_auth '/reports/unchecked', 'komagata'
    assert_button '未チェックの日報を一括で開く'
  end
end
