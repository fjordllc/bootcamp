# frozen_string_literal: true

require 'test_helper'

class CommentableTest < ActiveSupport::TestCase
  setup do
    @report = reports(:report1)
    @report.comments.delete_all
    now = Time.current
    # 最新コメントが古い順: machida(2分前), komagata(1分前), kimura(今)
    [
      [users(:komagata), 5.minutes],
      [users(:kimura), 4.minutes],
      [users(:machida), 2.minutes],
      [users(:komagata), 1.minute],
      [users(:kimura), 0.minutes]
    ].each do |user, ago|
      Comment.insert!({ user_id: user.id, commentable_type: 'Report', commentable_id: @report.id, # rubocop:disable Rails/SkipsModelValidations
                        description: 'コメント', created_at: now - ago, updated_at: now - ago })
    end
    @report.reload
  end

  test '#users_ordered_by_latest_comment returns users in the order of their latest comments' do
    expected = [users(:machida), users(:komagata), users(:kimura)]

    assert_equal expected, @report.users_ordered_by_latest_comment.to_a
    assert_equal expected, @report.comments.commented_users.to_a
  end

  test '#users_ordered_by_latest_comment returns the same users without queries when comments are preloaded' do
    expected = @report.comments.commented_users.to_a
    report = Report.preload(comments: :user).find(@report.id)

    assert_no_queries do
      assert_equal expected, report.users_ordered_by_latest_comment
    end
  end
end
