# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::PracticesTest < ApplicationSystemTestCase
  test 'show listing practices' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    assert_equal 'メンターページ | FBC', title
  end

  test 'show practice page' do
    visit_with_auth mentor_practices_path, 'mentormentaro'
    first('.admin-table__item').assert_text 'sshdでパスワード認証を禁止にする'
  end
end
