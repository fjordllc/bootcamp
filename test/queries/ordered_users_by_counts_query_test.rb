# frozen_string_literal: true

require 'test_helper'

class OrderedUsersByCountsQueryTest < ActiveSupport::TestCase
  test 'call' do
    ordered_users = OrderedUsersByCountsQuery.new(order_by: 'report', direction: 'desc').call
    more_report_user = users(:sotugyou)
    less_report_user = users(:mentormentaro)
    assert ordered_users.index(more_report_user) < ordered_users.index(less_report_user)

    ordered_users = OrderedUsersByCountsQuery.new(order_by: 'comment', direction: 'asc').call
    more_comment_user = users(:komagata)
    less_comment_user = users(:sotugyou)
    assert ordered_users.index(less_comment_user) < ordered_users.index(more_comment_user)
  end
end
