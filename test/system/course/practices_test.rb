# frozen_string_literal: true

require "application_system_test_case"

class Course::PracticesTest < ApplicationSystemTestCase
  setup { login_user "hatsuno", "testtest" }

  test "show listing practices" do
    visit "/courses/#{courses(:course_1).id}/practices"
    assert_equal "Rails Webプログラマーコースのプラクティス | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "change status" do
    practice = practices(:practice_1)
    visit "/courses/#{courses(:course_1).id}/practices"
    first("#practice_#{practice.id} .js-started").click
    sleep 5
    assert_equal "started", practice.status(users(:hatsuno))
  end
end
