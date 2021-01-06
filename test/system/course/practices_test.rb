# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  setup { login_user 'hatsuno', 'testtest' }

  test 'show listing practices' do
    visit "/courses/#{courses(:course1).id}/practices"
    assert_equal 'Rails Webプログラマーコース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end
end
