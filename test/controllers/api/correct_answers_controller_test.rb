# frozen_string_literal: true

require 'test_helper'

class API::CorrectAnswersControllerTest < ActionDispatch::IntegrationTest
  test 'Turbo selection and cancellation replace only status badges and actions' do
    sign_in(:komagata)
    answer = answers(:answer1)
    question = answer.question
    post api_answer_correct_answer_path(answer), params: { question_id: question.id }, as: :turbo_stream
    assert_response :ok
    assert_equal answer.id, question.reload.correct_answer.id
    assert_turbo_stream(action: 'replace', target: dom_id(question, :solved_status)) do
      assert_select 'template .js-solved-status', text: '解決済'
    end
    assert_turbo_stream(action: 'replace', target: "answer_badge_#{answer.id}") do
      assert_select 'template .best-answer-badge.correct-answer'
    end
    assert_select 'template textarea', count: 0
    assert_select 'turbo-stream[action="replace"][target=?]', "answer_#{answer.id}", count: 0

    patch api_answer_correct_answer_path(answer), params: { question_id: question.id }, as: :turbo_stream
    assert_response :ok
    assert_nil question.reload.correct_answer
    assert_turbo_stream(action: 'replace', target: dom_id(question, :solved_status)) do
      assert_select 'template .js-solved-status', text: '未解決'
    end
    assert_turbo_stream(action: 'replace', target: "answer_badge_#{answer.id}") do
      assert_select 'template .best-answer-badge.is-hidden'
    end
  end

  test 'repeated requests do not duplicate notifications and stale selection cannot replace another answer' do
    sign_in(:komagata)
    answer = answers(:answer1)
    other = answers(:answer2)
    events = []
    subscriber = ->(*args) { events << args.first }
    ActiveSupport::Notifications.subscribed(subscriber, /\A(answer|correct_answer)\.save\z/) do
      2.times { post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream }
      assert_equal %w[answer.save correct_answer.save], events
      post api_answer_correct_answer_path(other), params: { question_id: other.question_id }, as: :turbo_stream
      assert_response :unprocessable_entity
      assert_empty response.body
      assert_equal answer.id, answer.question.reload.correct_answer.id
      patch api_answer_correct_answer_path(other), params: { question_id: other.question_id }, as: :turbo_stream
      assert_response :ok
      assert_equal answer.id, answer.question.reload.correct_answer.id
      2.times { patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream }
      assert_equal %w[answer.save correct_answer.save answer.save], events
    end
  end

  test 'HTML selection and cancellation redirect to the answer and JSON keeps its success statuses' do
    sign_in(:komagata)
    answer = answers(:answer1)
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }
    assert_response :see_other
    assert_redirected_to question_path(answer.question, anchor: "answer_#{answer.id}")
    patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }
    assert_response :see_other
    assert_redirected_to question_path(answer.question, anchor: "answer_#{answer.id}")
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :json
    assert_response :ok
    patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :json
    assert_response :no_content
  end

  test 'failed HTML selection shows an alert and failed Turbo selection changes nothing' do
    sign_in(:komagata)
    answer = answers(:answer4)
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }
    assert_response :see_other
    assert_equal 'ベストアンサーを選択できませんでした。', flash[:alert]
    follow_redirect!
    assert_select '.flash.is-alert', text: /ベストアンサーを選択できませんでした。/
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
    assert_response :unprocessable_entity
    assert_empty response.body
    assert_equal correct_answers(:correct_answer1).id, answer.question.reload.correct_answer.id
  end

  test 'failed save is rejected and exceptions propagate' do
    sign_in(:komagata)
    answer = correct_answers(:correct_answer1)
    question = answer.question
    scope = question.answers
    Question.stub(:find, question) do
      question.stub(:answers, scope) do
        scope.stub(:find, answer) do
          answer.stub(:update, false) do
            patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }
            assert_response :see_other
            assert_equal 'ベストアンサーを取り消せませんでした。', flash[:alert]
          end
          answer.stub(:update, ->(*) { raise 'unexpected save failure' }) do
            assert_raises(RuntimeError) do
              patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
            end
          end
        end
      end
    end
    assert_equal answer.id, answer.question.reload.correct_answer.id
  end

  test 'question owner and non-admin mentor can select answers and other users cannot' do
    answer = answers(:answer3)
    sign_in(:sotugyou)
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
    assert_response :ok
    sign_in(:mentormentaro)
    patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
    assert_response :ok
    sign_in(:hajime)
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
    assert_response :forbidden
    assert_nil answer.question.reload.correct_answer
  end

  test 'read-only OAuth tokens cannot select or cancel a best answer' do
    application = Doorkeeper::Application.create!(name: 'Best answer test', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    token = Doorkeeper::AccessToken.create!(application: application, resource_owner_id: users(:komagata).id, scopes: 'read')
    answer = answers(:answer1)
    headers = { Authorization: "Bearer #{token.token}" }
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, headers: headers, as: :json
    assert_response :forbidden
    patch api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, headers: headers, as: :json
    assert_response :forbidden
    assert_nil answer.question.reload.correct_answer
  end

  test 'unauthenticated requests and answers from another question are rejected' do
    answer = answers(:answer1)
    post api_answer_correct_answer_path(answer), params: { question_id: answer.question_id }, as: :turbo_stream
    assert_response :unauthorized
    sign_in(:komagata)
    post api_answer_correct_answer_path(answer), params: { question_id: questions(:question2).id }, as: :turbo_stream
    assert_response :not_found
  end
end
