# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test 'shows basic campaign page through Rails' do
    get campaign_basic_path

    assert_response :success
    assert_includes response.body, '即戦力になれるプログラミングスクール'
    assert_includes response.body, '/campaigns/basic/assets/css/style.css'
  end

  test 'shows basic campaign page with trailing slash' do
    get '/campaigns/basic/'

    assert_response :success
    assert_includes response.body, '即戦力になれるプログラミングスクール'
  end

  test 'saves affiliate rd_code when visiting basic campaign page' do
    get campaign_basic_path(rd_code: 'test-rd_code_123')

    assert_response :success
    assert_equal 'test-rd_code_123', session[:affiliate_rd_code]
  end
end
