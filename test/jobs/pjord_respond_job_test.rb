# frozen_string_literal: true

require 'test_helper'

class PjordRespondJobTest < ActiveJob::TestCase
  setup do
    @pjord = users(:pjord)
  end

  test 'creates a comment reply when mentioned in a report comment' do
    comment = comments(:comment1)
    # after_commitコールバックの副作用を避けるため、DBを直接更新
    # rubocop:disable Rails/SkipsModelValidations
    comment.update_column(:description, '@pjord CSSについて教えて')
    # rubocop:enable Rails/SkipsModelValidations

    Pjord.stub(:respond, 'テストの回答です。') do
      assert_difference 'Comment.count', 1 do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: comment.id
        )
      end
    end

    reply = Comment.last
    assert_equal @pjord, reply.user
    assert_includes reply.description, "@#{comment.reload.sender.login_name}"
    assert_includes reply.description, 'テストの回答です。'
  end

  test 'creates an answer reply when mentioned in a question' do
    question = questions(:question1)
    # after_commitコールバックの副作用を避けるため、DBを直接更新
    # rubocop:disable Rails/SkipsModelValidations
    question.update_column(:description, '@pjord エディターについて教えて')
    # rubocop:enable Rails/SkipsModelValidations

    Pjord.stub(:respond, 'ヒントです。') do
      assert_difference 'Answer.count', 1 do
        PjordRespondJob.perform_now(
          mentionable_type: 'Question',
          mentionable_id: question.id
        )
      end
    end

    reply = Answer.last
    assert_equal @pjord, reply.user
    assert_includes reply.description, 'ヒントです。'
  end

  test 'does nothing when response is blank' do
    comment = comments(:comment1)
    # rubocop:disable Rails/SkipsModelValidations
    comment.update_column(:description, '@pjord テスト')
    # rubocop:enable Rails/SkipsModelValidations

    Pjord.stub(:respond, nil) do
      assert_no_difference 'Comment.count' do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: comment.id
        )
      end
    end
  end

  test 'does nothing when record is deleted' do
    # 存在しないIDを渡した場合、例外を投げずに何もしないことを確認
    assert_nothing_raised do
      assert_no_difference 'Comment.count' do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: 0
        )
      end
    end
  end

  test 'does nothing when mention is removed by edit' do
    comment = comments(:comment1)
    # メンションが含まれていないdescriptionをDBに直接セット
    # rubocop:disable Rails/SkipsModelValidations
    comment.update_column(:description, 'メンション削除済み')
    # rubocop:enable Rails/SkipsModelValidations

    Pjord.stub(:respond, '回答') do
      assert_no_difference 'Comment.count' do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: comment.id
        )
      end
    end
  end
end
