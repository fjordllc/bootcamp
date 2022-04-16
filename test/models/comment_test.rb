# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
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

  test 'notify only commented when comment on product' do
    Comment.create!(
      user: users(:mentormentaro),
      commentable: products(:product8),
      description: '提出物のコメントcreate'
    )
    assert users(:kimura).notifications.exists?(
      kind: 'watching',
      sender: users(:mentormentaro),
      message: 'kimuraさんの【 「PC性能の見方を知る」の提出物 】にmentormentaroさんがコメントしました。'
    )
    assert_not users(:mentormentaro).notifications.exists?(
      kind: 'submitted',
      sender: users(:kimura),
      message: 'kimuraさんが「PC性能の見方を知る」の提出物を提出しました。'
    )
  end

  test 'not notify when update comment on product' do
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
end
