# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test '.without_private_comment' do
    non_talk_comment_count = Comment.without_private_comment.count
    all_comment_count = Comment.count
    only_talk_comment_count = Comment.where(commentable_type: %w[Talk Inquiry CorporateTrainingInquiry]).count
    assert_equal non_talk_comment_count, all_comment_count - only_talk_comment_count
  end

  test '.commented_users' do
    report = reports(:report4)
    users = report.comments.commented_users
    sorted_users = report.comments.order(created_at: :desc).map(&:user).uniq.reverse
    assert_equal users, sorted_users
  end

  test '#anchor' do
    comment = comments(:comment1)
    assert_equal "comment_#{comment.id}", comment.anchor
  end

  test '#path' do
    comment = comments(:comment1)
    commentable = comment.commentable
    assert_equal "/reports/#{commentable.id}#comment_#{comment.id}", comment.path
  end

  test 'do not send notification if you post a mention in talks' do
    kimura = users(:kimura)
    kimura_talk = talks(:talk7)

    Comment.create!(
      user: kimura,
      commentable: kimura_talk,
      description: '@hatsuno test'
    )

    assert_not users(:hatsuno).notifications.exists?(
      kind: 'mentioned',
      sender: kimura
    )
  end

  test 'not notify mentor watching product of submitted when comment on product' do
    perform_enqueued_jobs do
      Comment.create!(
        user: users(:mentormentaro),
        commentable: products(:product8),
        description: '提出物のコメントcreate'
      )
      assert users(:kimura).notifications.exists?(
        kind: 'watching',
        sender: users(:mentormentaro),
        message: 'kimuraさんの提出物「PC性能の見方を知る」にmentormentaroさんがコメントしました。'
      )
    end
    assert_not users(:mentormentaro).notifications.exists?(
      kind: 'submitted',
      sender: users(:kimura),
      message: 'kimuraさんが「PC性能の見方を知る」の提出物を提出しました。'
    )
  end

  test 'watch mentor not notify submitted when comment on product' do
    comment = comments(:comment14)
    # 数が変わっていない(通知は来ないことをテスト)
    assert_difference -> { users(:sotugyou).notifications.where(kind: 'watching', sender: users(:mentormentaro)).count }, 0 do
      comment.update!(description: '提出物のコメントupdate')
    end
  end

  test 'not notify when destroy comment on product' do
    comment = comments(:comment14)
    # 数が変わっていない(通知は来ないことをテスト)
    assert_difference -> { users(:sotugyou).notifications.where(kind: 'watching', sender: users(:mentormentaro)).count }, 0 do
      comment.destroy!
    end
  end

  test '#certain_period_passed_since_the_last_comment_by_submitter?' do
    Comment.create!(
      user: users(:komagata),
      commentable: products(:product8),
      description: '提出物への最初のコメント',
      created_at: Time.current.ago(4.days)
    )

    last_comment = Comment.create!(
      user: users(:kimura),
      commentable: products(:product8),
      description: '提出物への提出者による最後のコメントかつ、投稿から3日経過',
      created_at: Time.current.ago(3.days)
    )

    assert last_comment.certain_period_passed_since_the_last_comment_by_submitter?(3.days)
  end

  test '#title returns commentable title if present' do
    comment = comments(:comment1)
    assert_equal '作業週1日目', comment.title
  end
end
