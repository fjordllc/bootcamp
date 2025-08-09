# frozen_string_literal: true

require 'application_system_test_case'

class Course::PracticesTest < ApplicationSystemTestCase
  test 'show listing practices' do
    visit_with_auth "/courses/#{courses(:course1).id}/practices", 'kimura'
    assert_equal 'Railsエンジニアコース | FBC', title
  end

  test 'practices by category on practice list page will be in order' do
    visit_with_auth course_practices_path(courses(:course1).id), 'hatsuno'
    within('.page-body__columns .categories-item:first-child .category-practices-item:first-child') do
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
