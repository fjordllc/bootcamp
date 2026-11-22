# frozen_string_literal: true

require 'application_system_test_case'

class InquiryCommentsTest < ApplicationSystemTestCase
  test 'post new comment for inquiry' do
    visit_with_auth "/admin/inquiries/#{inquiries(:inquiry1).id}", 'komagata'
    within('.thread-comment-form__form') do
      fill_in('comment[description]', with: 'test')
    end
    all('.a-form-tabs__tab.js-tabs__tab')[1].click
    assert_text 'test'
    click_button 'コメントする'
    assert_text 'test'
  end
end
