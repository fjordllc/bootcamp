# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::HomeTest < ApplicationSystemTestCase
  test 'GET /mentor' do
    visit_with_auth '/mentor', 'komagata'
    assert_equal 'メンターページ | FBC', title
    assert_no_text 'jobseeker (就活 のぞむ)'
    assert_text 'muryou (Muryou Nosuke)'
  end

  test 'accessed by non-mentor users' do
    visit_with_auth '/mentor', 'kimura'
    assert_text 'メンターとしてログインしてください'
  end
end
