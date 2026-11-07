# frozen_string_literal: true

require 'test_helper'

class API::AnswerDeletionsControllerTest < ActionDispatch::IntegrationTest
  test 'Turbo deletion removes only the answer and updates the count' do
    sign_in(:komagata)
    answer = answers(:answer1)
    question = answer.question
    count = question.answers.count
    assert_difference 'Answer.count', -1 do
      delete api_answer_path(answer), as: :turbo_stream
    end
    assert_response :ok
    assert_select 'turbo-stream', count: 2
    assert_turbo_stream(action: 'remove', target: "answer_#{answer.id}")
    assert_turbo_stream(action: 'replace', target: "answer_count_question_#{question.id}") do
      assert_select 'template .js-answer-count', text: (count - 1).to_s
    end
  end

  test 'deleting the last answer renders a zero count' do
    sign_in(:komagata)
    answer = answers(:answer3)
    assert_equal 1, answer.question.answers.count
    delete api_answer_path(answer), as: :turbo_stream
    assert_response :ok
    assert_select 'template .js-answer-count.is-zero', text: '0'
  end

  test 'deleting the best answer updates the status and remaining actions without replacing editors' do
    sign_in(:komagata)
    answer = correct_answers(:correct_answer1)
    question = answer.question
    remaining = question.answers.where.not(id: answer.id).to_a
    delete api_answer_path(answer), as: :turbo_stream

    assert_response :ok
    assert_nil question.reload.correct_answer
    assert_turbo_stream(action: 'replace', target: "solved_status_question_#{question.id}") do
      assert_select 'template .js-solved-status', text: '未解決'
    end
    remaining.each do |other|
      assert_turbo_stream(action: 'replace', target: "answer_actions_#{other.id}") do
        assert_select 'template .make-best-answer-button.is-hidden', count: 0
      end
    end
    assert_select 'template textarea', count: 0
  end

  test 'HTML deletion redirects to the question answer list' do
    sign_in(:komagata)
    answer = answers(:answer1)
    delete api_answer_path(answer)
    assert_redirected_to question_path(answer.question, anchor: "answers_question_#{answer.question_id}")
    assert_response :see_other
  end

  test 'JSON deletion keeps its response format' do
    sign_in(:komagata)
    answer = answers(:answer1)
    delete api_answer_path(answer), as: :json
    assert_response :ok
    assert_equal({ 'id' => answer.id }, response.parsed_body)
  end

  test 'failed deletion keeps the answer and returns an HTML alert or Turbo error' do
    sign_in(:komagata)
    answer = answers(:answer1)
    Answer.stub(:find_by, answer) do
      answer.stub(:destroy, false) do
        assert_no_difference 'Answer.count' do
          delete api_answer_path(answer)
        end
        assert_response :see_other
        assert_redirected_to question_path(answer.question, anchor: "answer_#{answer.id}")
        assert_equal '回答を削除できませんでした。', flash[:alert]
        delete api_answer_path(answer), as: :turbo_stream
        assert_response :unprocessable_entity
        assert_empty response.body
        answer.errors.add(:base, '削除できません')
        delete api_answer_path(answer), as: :json
        assert_response :unprocessable_entity
        assert_equal ['削除できません'], response.parsed_body.dig('errors', 'base')
      end
    end
  end

  test 'failed best answer deletion does not emit the cache invalidation event or update the screen' do
    sign_in(:komagata)
    answer = correct_answers(:correct_answer1)
    events = []
    subscriber = ->(*arguments) { events << arguments }
    ActiveSupport::Notifications.subscribed(subscriber, 'answer.destroy') do
      Answer.stub(:find_by, answer) do
        answer.stub(:destroy, false) do
          delete api_answer_path(answer), as: :turbo_stream
        end
      end
    end
    assert_response :unprocessable_entity
    assert_empty response.body
    assert_empty events
    assert_equal answer.id, answer.question.reload.correct_answer.id
  end

  test 'unexpected deletion exceptions propagate' do
    sign_in(:komagata)
    answer = answers(:answer1)
    Answer.stub(:find_by, answer) do
      answer.stub(:destroy, -> { raise 'unexpected deletion failure' }) do
        assert_raises(RuntimeError) { delete api_answer_path(answer), as: :turbo_stream }
      end
    end
    assert Answer.exists?(answer.id)
  end

  test 'non-admin mentor can delete own answers but not another user answer' do
    sign_in(:mentormentaro)
    own = Answer.create!(question: questions(:question1), user: users(:mentormentaro), description: '本人の回答')
    delete api_answer_path(own), as: :turbo_stream
    assert_response :ok
    other = answers(:answer1)
    assert_no_difference 'Answer.count' do
      delete api_answer_path(other), as: :turbo_stream
    end
    assert_response :not_found
  end

  test 'unauthenticated deletion is rejected' do
    assert_no_difference 'Answer.count' do
      delete api_answer_path(answers(:answer1)), as: :turbo_stream
    end
    assert_response :unauthorized
  end
end
