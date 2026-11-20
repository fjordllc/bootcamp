# frozen_string_literal: true

require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  test 'edit URL opens only the selected answer for its owner' do
    sign_in(:sotugyou)
    answer = answers(:answer2)
    get question_path(answer.question, edit_answer_id: answer.id)

    assert_response :ok
    assert_select "#answer_#{answer.id} .answer-display.is-hidden"
    assert_select "#answer_editor_#{answer.id}:not(.is-hidden) textarea", text: answer.description
    assert_select "#answer_#{answers(:answer1).id} .answer-editor.is-hidden"
    assert_select '.new-answer textarea', text: ''
  end

  test 'edit URL preserves admin and non-admin mentor permissions' do
    answer = answers(:answer2)
    sign_in(:komagata)
    get question_path(answer.question, edit_answer_id: answer.id)
    assert_response :ok

    sign_in(:mentormentaro)
    get question_path(answer.question, edit_answer_id: answer.id)
    assert_response :not_found
  end

  test 'edit URL rejects another question answer and nonexistent answers' do
    sign_in(:komagata)
    get question_path(questions(:question2), edit_answer_id: answers(:answer1).id)
    assert_response :not_found
    get question_path(questions(:question2), edit_answer_id: 0)
    assert_response :not_found
  end

  test 'non-admin mentor sees edit and delete controls only for own answers and keeps best answer controls' do
    sign_in(:mentormentaro)
    question = questions(:question1)
    own = Answer.create!(question: question, user: users(:mentormentaro), description: 'メンター本人の回答')
    other = answers(:answer1)
    get question_path(question)

    assert_response :ok
    assert_select "#answer_actions_#{own.id} .edit-button"
    assert_select "#answer_actions_#{own.id} .delete-button"
    assert_select "#answer_actions_#{other.id} .edit-button", count: 0
    assert_select "#answer_actions_#{other.id} .delete-button", count: 0
    assert_select "#answer_actions_#{other.id} .make-best-answer"
  end

  test 'answer owners and admins keep edit and delete controls' do
    answer = answers(:answer2)
    sign_in(:sotugyou)
    get question_path(answer.question)
    assert_response :ok
    assert_select "#answer_actions_#{answer.id} .edit-button"
    assert_select "#answer_actions_#{answer.id} .delete-button"
    assert_select "#answer_actions_#{answers(:answer1).id} .edit-button", count: 0
    assert_select "#answer_actions_#{answers(:answer1).id} .delete-button", count: 0

    sign_in(:komagata)
    get question_path(answer.question)
    assert_response :ok
    assert_select "#answer_actions_#{answer.id} .edit-button"
    assert_select "#answer_actions_#{answer.id} .delete-button"
  end

  test 'regular user cannot delete a question' do
    token = create_token('kimura', 'testtest')
    user = users(:kimura)

    post user_sessions_path, params: {
      authenticity_token: token, user: {
        login: user.login_name, password: 'testtest'
      }
    }
    follow_redirect!

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to root_path
    assert_equal '管理者・メンターとしてログインしてください', flash[:alert]
  end

  test 'admin can delete a question' do
    token = create_token('adminonly', 'testtest')
    user = users(:adminonly)

    post user_sessions_path, params: {
      authenticity_token: token, user: {
        login: user.login_name, password: 'testtest'
      }
    }
    follow_redirect!

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to questions_path
    assert_equal '質問を削除しました。', flash[:notice]
  end

  test 'mentor can delete a question' do
    token = create_token('mentormentaro', 'testtest')
    user = users(:mentormentaro)

    post user_sessions_path, params: {
      authenticity_token: token, user: {
        login: user.login_name, password: 'testtest'
      }
    }
    follow_redirect!

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to questions_path
    assert_equal '質問を削除しました。', flash[:notice]
  end
end
