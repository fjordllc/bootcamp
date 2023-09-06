# frozen_string_literal: true

require 'test_helper'

class NavigationHelperTest < ActionView::TestCase
  include BodyClassHelper

  test 'current_link' do
    def controller_path
      'practices'
    end

    assert_equal 'is-active', current_link(/^practices/)
    assert_not_equal 'is-active', current_link(/^test/)

    def controller_path
      'practices/products'
    end

    assert_equal 'is-active', current_link(/^practices/)

    def controller_path
      'practices/reports'
    end

    assert_equal 'is-active', current_link(/^practices/)

    def controller_path
      'reports'
    end

    assert_equal 'is-active', current_link(/^reports/)

    def controller_path
      'questions'
    end

    assert_equal 'is-active', current_link(/^questions/)

    def controller_path
      'users'
    end

    assert_equal 'is-active', current_link(/^users/)

    def controller_path
      'pages'
    end

    assert_equal 'is-active', current_link(/^pages/)

    def controller_path
      'admin/categories'
    end

    assert_equal 'is-active', current_link(/^admin-categories/)

    def controller_path
      'admin/categories'
    end

    assert_equal 'is-active', current_link(/^admin-categories/)

    def controller_path
      'admin/home'
    end

    assert_equal 'is-active', current_link(/^admin-home/)
  end
end
