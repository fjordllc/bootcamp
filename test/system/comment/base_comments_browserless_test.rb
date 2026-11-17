# frozen_string_literal: true

require 'browserless_system_test_case'

class BaseCommentsBrowserlessTest < BrowserlessSystemTestCase
  test 'show all comments for reports of the target user' do
    visit_with_auth polymorphic_path([users(:komagata), :comments]), 'komagata'
    assert_equal 4, users(:komagata).comments.where(commentable_type: 'Report').size
  end
end
