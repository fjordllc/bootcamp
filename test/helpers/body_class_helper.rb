# frozen_string_literal: true

require 'test_helper'

class BodyClassHelperTest < ActionView::TestCase
  include TagHelper

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
end
