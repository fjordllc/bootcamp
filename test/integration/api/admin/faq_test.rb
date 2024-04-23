# frozen_string_literal: true

require 'test_helper'

class API::Admin::FAQTest < ActionDispatch::IntegrationTest
  test 'PATCH /api/admin/faqs/:id' do
    target = faqs(:faq1)

    invalid_token = create_token('hatsuno', 'testtest')
    patch api_admin_faq_path(target),
          headers: { 'Authorization' => "Bearer #{invalid_token}" }
    assert_response :unauthorized

    valid_token = create_token('komagata', 'testtest')
    patch(
      api_admin_faq_path(target),
      params: { insert_at: 2 },
      headers: { 'Authorization' => "Bearer #{valid_token}" }
    )
    assert_response :no_content
  end
end
