# frozen_string_literal: true

require 'test_helper'

class ReportsHelperTest < ActionView::TestCase
  include Sorcery::Controller::InstanceMethods
  include Sorcery::TestHelpers::Rails::Controller

  test 'practice_options_within_course' do
    login_user(users(:kimura))
    assert_equal 'OS X Mountain Lionをクリーンインストールする', practice_options_within_course.first[0]
    assert_equal '企業研究', practice_options_within_course.last[0]
    assert_no_difference 'practice_options_within_course.count' do
      CategoriesPractice.create!(category_id: categories(:category2).id, practice_id: practices(:practice2).id, position: 7)
    end
  end
end
