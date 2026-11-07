# frozen_string_literal: true

require 'test_helper'

class API::AnswerUpdatesControllerTest < ActionDispatch::IntegrationTest
  test 'Turbo update replaces only the saved answer' do
    sign_in(:komagata)
    answer = answers(:answer2)
    patch api_answer_path(answer), params: { answer: { description: '保存済みの編集内容' } }, as: :turbo_stream

    assert_response :ok
    assert_equal '保存済みの編集内容', answer.reload.description
    assert_select 'turbo-stream', count: 1
    assert_turbo_stream(action: 'replace', target: "answer_#{answer.id}") do
      assert_select 'template .answer-text', text: '保存済みの編集内容'
      assert_select 'template .answer-editor.is-hidden'
    end
  end

  test 'invalid Turbo update keeps the input in the editor and does not change the answer' do
    sign_in(:sotugyou)
    answer = answers(:answer2)
    original = answer.description
    description = " \n "
    patch api_answer_path(answer), params: { answer: { description: } }, as: :turbo_stream

    assert_response :unprocessable_entity
    assert_equal original, answer.reload.description
    assert_select 'turbo-stream', count: 1
    assert_turbo_stream(status: :unprocessable_entity, action: 'replace', target: "answer_editor_#{answer.id}") do
      assert_select 'template .errors'
      assert_select 'template textarea' do |elements|
        assert_equal description, elements.first.content
      end
      assert_select 'template .answer-editor.is-hidden', count: 0
    end
  end

  test 'HTML update redirects to the answer' do
    sign_in(:sotugyou)
    answer = answers(:answer2)
    patch api_answer_path(answer), params: { answer: { description: 'HTMLで更新' } }

    assert_response :see_other
    assert_redirected_to question_path(answer.question, anchor: "answer_#{answer.id}")
    assert_equal 'HTMLで更新', answer.reload.description
  end

  test 'invalid HTML update keeps the editor separate from the new answer' do
    sign_in(:sotugyou)
    answer = answers(:answer2)
    original = answer.description
    patch api_answer_path(answer), params: { answer: { description: '   ' } }

    assert_response :unprocessable_entity
    assert_equal original, answer.reload.description
    assert_select "#answer_#{answer.id} .answer-display.is-hidden"
    assert_select "#answer_editor_#{answer.id} .errors"
    assert_select "#answer_editor_#{answer.id} textarea" do |elements|
      assert_equal '   ', elements.first.content
    end
    assert_select '.new-answer textarea', text: ''
    assert_select '.new-answer .errors', count: 0
  end

  test 'JSON update and validation errors keep their existing format' do
    sign_in(:sotugyou)
    answer = answers(:answer2)
    patch api_answer_path(answer), params: { answer: { description: 'JSONで更新' } }, as: :json
    assert_response :ok
    assert_equal answer.id, response.parsed_body['id']
    assert_equal 'JSONで更新', response.parsed_body['description']

    patch api_answer_path(answer), params: { answer: { description: '' } }, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body['errors']['description'].present?
    assert_equal 'JSONで更新', answer.reload.description
  end

  test 'best answer keeps its type and stable DOM ID after editing' do
    sign_in(:komagata)
    answer = correct_answers(:correct_answer1)
    patch api_answer_path(answer), params: { answer: { description: '編集したベストアンサー' } }, as: :turbo_stream

    assert_response :ok
    assert_equal 'CorrectAnswer', answer.reload.type
    assert_turbo_stream(action: 'replace', target: "answer_#{answer.id}") do
      assert_select 'template .best-answer-badge.correct-answer'
      assert_select 'template form[action=?]', api_answer_path(answer)
    end
  end

  test 'non-admin mentor can update own answers but not another user answer' do
    sign_in(:mentormentaro)
    own = Answer.create!(question: questions(:question1), user: users(:mentormentaro), description: '本人の回答')
    patch api_answer_path(own), params: { answer: { description: '更新した本人の回答' } }, as: :turbo_stream
    assert_response :ok
    assert_equal '更新した本人の回答', own.reload.description

    other = answers(:answer1)
    original = other.description
    patch api_answer_path(other), params: { answer: { description: '更新できない回答' } }, as: :turbo_stream
    assert_response :not_found
    assert_equal original, other.reload.description
  end

  test 'update rejects other users and unauthenticated requests' do
    answer = answers(:answer1)
    original = answer.description
    patch api_answer_path(answer), params: { answer: { description: '未認証' } }, as: :turbo_stream
    assert_response :unauthorized

    sign_in(:sotugyou)
    patch api_answer_path(answer), params: { answer: { description: '他人の回答' } }, as: :turbo_stream
    assert_response :not_found
    assert_equal original, answer.reload.description
  end
end
