# frozen_string_literal: true

require 'test_helper'

class PjordRespondJobTest < ActiveJob::TestCase
  test 'creates a comment reply when mentioned in a report comment' do
    comment = comments(:comment1)
    pjord = users(:pjord)

    Pjord.stub(:respond, 'テストの回答です。') do
      assert_difference 'Comment.count', 1 do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: comment.id
        )
      end
    end

    reply = Comment.last
    assert_equal pjord, reply.user
    assert_includes reply.description, "@#{comment.sender.login_name}"
    assert_includes reply.description, 'テストの回答です。'
  end

  test 'creates an answer reply when mentioned in a question' do
    question = questions(:question1)
    pjord = users(:pjord)

    Pjord.stub(:respond, 'ヒントです。') do
      assert_difference 'Answer.count', 1 do
        PjordRespondJob.perform_now(
          mentionable_type: 'Question',
          mentionable_id: question.id
        )
      end
    end

    reply = Answer.last
    assert_equal pjord, reply.user
    assert_includes reply.description, 'ヒントです。'
  end

  test 'does nothing when response is blank' do
    comment = comments(:comment1)

    Pjord.stub(:respond, nil) do
      assert_no_difference 'Comment.count' do
        PjordRespondJob.perform_now(
          mentionable_type: 'Comment',
          mentionable_id: comment.id
        )
      end
    end
  end
end
