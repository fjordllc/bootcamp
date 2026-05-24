# frozen_string_literal: true

require 'test_helper'

class PjordQuestionAnswerJobTest < ActiveJob::TestCase
  test 'creates an answer by pjord for a question' do
    question = questions(:question1)
    pjord = users(:pjord)

    Pjord::QuestionAnswerAgent.stub(:answer, 'ヒントをあげるね！') do
      assert_difference 'Answer.count', 1 do
        PjordQuestionAnswerJob.perform_now(question_id: question.id)
      end
    end

    answer = Answer.last
    assert_equal pjord, answer.user
    assert_equal question, answer.question
    assert_equal 'ヒントをあげるね！', answer.description
  end

  test 'does nothing when question is not found' do
    assert_no_difference 'Answer.count' do
      PjordQuestionAnswerJob.perform_now(question_id: 0)
    end
  end

  test 'does nothing when pjord user is not found' do
    question = questions(:question1)

    Pjord.stub(:user, nil) do
      assert_no_difference 'Answer.count' do
        PjordQuestionAnswerJob.perform_now(question_id: question.id)
      end
    end
  end

  test 'does nothing when response is blank' do
    question = questions(:question1)

    Pjord::QuestionAnswerAgent.stub(:answer, nil) do
      assert_no_difference 'Answer.count' do
        PjordQuestionAnswerJob.perform_now(question_id: question.id)
      end
    end
  end

  test 'passes question to question answer agent' do
    question = questions(:question1)
    captured_question = nil

    answer = lambda { |passed_question|
      captured_question = passed_question
      'テスト回答'
    }

    Pjord::QuestionAnswerAgent.stub(:answer, answer) do
      PjordQuestionAnswerJob.perform_now(question_id: question.id)
    end

    assert_equal question, captured_question
  end
end
