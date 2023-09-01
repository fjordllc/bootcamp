# frozen_string_literal: true

require 'test_helper'

class BodyClassHelperTest < ActionView::TestCase
  test 'qualified_controller_name' do
    def controller_path
      'practices/products'
    end

    assert_equal 'practices-products', qualified_controller_name

    def controller_path
      'practices'
    end

    assert_equal 'practices', qualified_controller_name

    def controller_path
      'admin/users/password'
    end

    assert_equal 'admin-users-password', qualified_controller_name
  end

  test 'controller_class' do
    def qualified_page_name
      "#{qualified_controller_name}-#{action_name}"
    end

    def controller_path
      'practices/products'
    end

    def action_name
      'index'
    end

    assert_equal 'practices-products practices-products-index', controller_class

    def controller_path
      'practices'
    end

    assert_equal 'practices practices-index', controller_class

    def controller_path
      'admin/users/password'
    end

    assert_equal 'admin-users-password admin-users-password-index', controller_class
  end
end
