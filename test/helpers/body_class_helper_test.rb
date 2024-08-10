# frozen_string_literal: true

require 'test_helper'

class BodyClassHelperTest < ActionView::TestCase
  include NavigationHelper

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

  test 'page_category' do
    params[:action] = 'new'

    assert_equal 'edit-page', page_category

    params[:action] = 'create'

    assert_equal 'edit-page', page_category

    params[:action] = 'edit'

    assert_equal 'edit-page', page_category

    params[:action] = 'index'

    assert_equal 'index-page', page_category

    params[:action] = 'show'

    assert_equal 'show-page', page_category

    params[:action] = 'destroy'

    assert_equal 'other-page', page_category
  end

  test 'adviser_mode' do
    def adviser_login?
      true
    end

    assert_equal 'is-adviser-mode', adviser_mode

    def adviser_login?
      false
    end

    assert_nil adviser_mode
  end

  test 'page_area' do
    def controller_path
      'admin/users'
    end

    assert_equal 'admin-page', page_area

    def controller_path
      'welcome'
    end

    assert_equal 'welcome-page', page_area

    def controller_path
      'articles'
    end

    params[:action] = 'index'

    assert_equal 'welcome-page', page_area

    params[:action] = 'show'

    assert_equal 'welcome-page', page_area

    params[:action] = 'new'

    assert_equal 'learning-page', page_area

    def controller_path
      'practices'
    end

    params[:action] = 'new'

    assert_equal 'learning-page', page_area
  end

  test 'admin_page?' do
    def controller_path
      'admin/users'
    end

    assert admin_page?

    def controller_path
      'practices/products'
    end

    assert_not admin_page?
  end

  test 'controller_class' do
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

  test 'body_class' do
    def controller_path
      'admin/users'
    end

    def action_name
      'index'
    end

    def adviser_login?
      true
    end

    params[:action] = 'new'

    assert_equal 'admin-users admin-users-index is-edit-page is-admin-page is-test is-adviser-mode', body_class

    content_for(:extra_body_classes, 'no-recent-reports')

    assert_equal 'admin-users admin-users-index is-edit-page is-admin-page is-test is-adviser-mode no-recent-reports', body_class

    options = { extra_body_classes_symbol: :test }
    content_for(:test, 'test')

    assert_equal 'admin-users admin-users-index is-edit-page is-admin-page is-test is-adviser-mode test', body_class(options)
  end
end
