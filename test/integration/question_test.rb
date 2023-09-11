# frozen_string_literal: true

require 'test_helper'

class QuestionDeleteTest < ActionDispatch::IntegrationTest
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

    assert_redirected_to questions_path
    assert_equal 'メンター/管理者以外は質問を削除できません。', flash[:notice]
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
