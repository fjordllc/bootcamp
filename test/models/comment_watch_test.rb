# frozen_string_literal: true

require 'test_helper'

class CommentWatchTest < ActiveSupport::TestCase
  setup do
    @user = users(:mentormentaro)
    @report = reports(:report1)
    @comment = Comment.create!(user: @user, commentable: @report, description: 'ウォッチ確認用のtestコメント')
  end

  test 'commenting makes the commenter a watcher' do
    assert @user.watches.exists?(watchable: @report)
  end

  test 'updating a comment after removing the watch does not watch again' do
    @user.watches.where(watchable: @report).destroy_all

    @comment.update!(description: 'ウォッチ確認用のtestコメントを編集')

    assert_not @user.watches.exists?(watchable: @report)
  end

  test 'deleting a comment after removing the watch does not watch again' do
    @user.watches.where(watchable: @report).destroy_all

    @comment.destroy!

    assert_not @user.watches.exists?(watchable: @report)
  end
end
