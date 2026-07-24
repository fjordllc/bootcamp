# frozen_string_literal: true

require 'test_helper'

class CommentNotifierForAdminTest < ActiveSupport::TestCase
  test '#call notifies admins except comment sender' do
    comment = comments(:commentOfTalk)
    expected_count = User.admins.where.not(id: comment.sender.id).count

    assert_difference -> { AbstractNotifier::Testing::Driver.enqueued_deliveries.count }, expected_count do
      CommentNotifierForAdmin.new.call(nil, nil, nil, nil, { comment: })
    end
  end
end
