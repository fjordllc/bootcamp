# frozen_string_literal: true

require 'test_helper'

class QuestionIntegrationTest < ActionDispatch::IntegrationTest
  test 'regular user cannot delete a question' do
    user = users(:kimura)
    post user_sessions_path, params: { user: { login: user.login_name, password: 'testtest' } }

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to root_path
    assert_equal '管理者・メンターとしてログインしてください', flash[:alert]
  end

  test 'admin can delete a question' do
    user = users(:adminonly)
    post user_sessions_path, params: { user: { login: user.login_name, password: 'testtest' } }

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to questions_path
    assert_equal '質問を削除しました。', flash[:notice]
  end

  test 'mentor can delete a question' do
    user = users(:mentormentaro)
    post user_sessions_path, params: { user: { login: user.login_name, password: 'testtest' } }

    question = questions(:question8)
    delete question_path(question)

    assert_redirected_to questions_path
    assert_equal '質問を削除しました。', flash[:notice]
  end
end
