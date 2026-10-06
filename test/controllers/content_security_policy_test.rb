# frozen_string_literal: true

require 'test_helper'

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test 'public pages send a supplementary report-only policy' do
    get root_path

    assert_response :success
    policy = response.headers['Content-Security-Policy-Report-Only']
    assert policy, 'report-only CSP header is present'
    assert_includes policy, "object-src 'none'"
    assert_includes policy, "base-uri 'self'"
    assert_includes policy, "frame-ancestors 'self'"
    assert_includes policy, 'https://ga.jspm.io'
    assert_includes policy, 'https://esm.sh'
    assert_not_includes policy, 'report-uri'
    assert_not_includes policy, 'report-to'
    assert_nil response.headers['Content-Security-Policy']
  end
end
