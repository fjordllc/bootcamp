# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  setup { login_user 'hatsuno', 'testtest' }

  test 'show listing practices' do
    visit "/courses/#{courses(:course1).id}/practices"
    assert_equal 'Rails Webプログラマーコース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show/hide the progress of others' do
    visit practice_path(practices(:practice1).id)
    click_button '着手'
    visit course_practices_path(courses(:course1).id)

    assert page.find(:css, '#displayProgress', visible: false).checked?
    assert_not has_selector?('.is-hidden-users')
    user_path = user_path(users(:hatsuno).id)
    within page.find('.categories-items__inner') do
      assert page.has_link?(href: user_path)
    end

    page.find('#checkboxProgress').click
    assert_not page.find(:css, '#displayProgress', visible: false).checked?
    assert has_selector?('.is-hidden-users')
    within page.find('.categories-items__inner') do
      assert page.has_no_link?(href: user_path)
    end
  end
end
