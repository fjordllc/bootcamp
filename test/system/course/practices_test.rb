# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  test 'show listing practices' do
    visit_with_auth "/courses/#{courses(:course1).id}/practices", 'kimura'
    assert_equal 'Rails Webプログラマーコース | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show/hide the progress of others' do
    visit_with_auth practice_path(practices(:practice1)), 'hatsuno'
    click_button '着手'
    visit course_practices_path(courses(:course1).id)

    assert page.find(:css, '#display-progress', visible: false).checked?
    assert_not has_selector?('.is-hidden-users')
    user_path = user_path(users(:hatsuno).id)
    within page.find('.categories-items__inner') do
      assert page.has_link?(href: user_path)
    end

    page.find('#checkbox-progress').click
    assert_not page.find(:css, '#display-progress', visible: false).checked?
    assert has_selector?('.is-hidden-users')
    within page.find('.categories-items__inner') do
      assert page.has_no_link?(href: user_path)
    end
  end

  test 'practices by category on practice list page will be in order' do
    visit_with_auth course_practices_path(courses(:course1).id), 'hatsuno'
    within('.categories-items .categories-item:first-child .category-practices-item:first-child') do
      assert_text 'OS X Mountain Lionをクリーンインストールする'
    end
  end

  test 'navi menu on practice show page will be in order' do
    visit_with_auth practice_path(practices(:practice1).id), 'hatsuno'
    within('.page-nav .page-nav__item:first-child') do
      assert_text 'OS X Mountain Lionをクリーンインストールする'
    end
  end
end
