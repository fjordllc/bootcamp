# frozen_string_literal: true

require 'test_helper'

class PracticeQuizzesTest < ActionDispatch::IntegrationTest
  test 'student can pass practice quiz and then complete practice' do
    user = users(:kimura)
    practice = practices(:practice3)
    quiz, question = create_quiz(practice)
    login(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :unprocessable_entity
    assert_equal '理解度テストに合格すると、このプラクティスを修了できます。', response.parsed_body['error']

    post practice_practice_quiz_attempts_path(practice), params: {
      answers: {
        question.id => [question.practice_quiz_choices.find_by!(correct: true).id]
      }
    }

    assert_redirected_to practice_practice_quiz_path(practice)
    assert quiz.passed_by?(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :success
    assert Learning.find_by!(user:, practice:).complete?
  end

  test 'student can complete submission practice without quiz as before' do
    user = users(:kimura)
    practice = practices(:practice5)
    login(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :success
    assert Learning.find_by!(user:, practice:).complete?
  end

  test 'student cannot retry quiz within one hour after failure' do
    user = users(:kimura)
    practice = practices(:practice3)
    _quiz, question = create_quiz(practice)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: {
      answers: {
        question.id => [question.practice_quiz_choices.find_by!(correct: false).id]
      }
    }

    assert_redirected_to practice_practice_quiz_path(practice)

    assert_no_difference 'PracticeQuizAttempt.count' do
      post practice_practice_quiz_attempts_path(practice), params: {
        answers: {
          question.id => [question.practice_quiz_choices.find_by!(correct: true).id]
        }
      }
    end
    assert_redirected_to practice_practice_quiz_path(practice)
  end

  private

  def login(user)
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end

  def create_quiz(practice)
    quiz = PracticeQuiz.create!(practice:, published: false)
    question = quiz.practice_quiz_questions.create!(
      question_type: :single_choice,
      body: '正しいものを選んでください。',
      explanation: '解説です。',
      position: 1,
      published: false
    )
    question.practice_quiz_choices.create!(body: '正解', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 2)
    question.update!(published: true)
    quiz.update!(published: true)
    [quiz, question]
  end
end
