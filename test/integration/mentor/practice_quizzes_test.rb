# frozen_string_literal: true

require 'test_helper'

class Mentor::PracticeQuizzesTest < ActionDispatch::IntegrationTest
  test 'mentor can navigate to practice quiz management from practice page tab' do
    practice = practices(:practice3)
    PracticeQuiz.create!(practice:, published: false)
    login(users(:mentormentaro))

    get practice_path(practice)

    assert_response :success
    assert_select 'a[href=?]', edit_mentor_practice_practice_quiz_path(practice), text: '理解度テスト管理'
  end

  test 'mentor can navigate to new practice quiz from practice page tab when quiz does not exist' do
    practice = practices(:practice4)
    login(users(:mentormentaro))

    get practice_path(practice)

    assert_response :success
    assert_select 'a[href=?]', new_mentor_practice_practice_quiz_path(practice), text: '理解度テスト管理'
  end

  test 'mentor creates practice quiz and question' do
    practice = practices(:practice3)
    login(users(:mentormentaro))

    post mentor_practice_practice_quiz_path(practice), params: {
      practice_quiz: {
        published: '0'
      }
    }

    assert_redirected_to edit_mentor_practice_practice_quiz_path(practice)
    quiz = practice.reload.practice_quiz
    assert_not_predicate quiz, :published?

    post mentor_practice_practice_quiz_questions_path(practice), params: {
      practice_quiz_question: {
        question_type: 'single_choice',
        body: '正しいものを選んでください。',
        explanation: '解説です。',
        position: 1,
        published: '1',
        practice_quiz_choices_attributes: {
          '0' => { body: '正解', correct: '1', position: 1 },
          '1' => { body: '不正解', correct: '0', position: 2 }
        }
      }
    }

    assert_redirected_to edit_mentor_practice_practice_quiz_path(practice)
    assert_equal 1, quiz.practice_quiz_questions.count

    patch mentor_practice_practice_quiz_path(practice), params: {
      practice_quiz: {
        published: '1'
      }
    }

    assert_redirected_to edit_mentor_practice_practice_quiz_path(practice)
    assert_predicate quiz.reload, :published?
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
end
