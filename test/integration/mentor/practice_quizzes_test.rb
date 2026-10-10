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

  test 'mentor form has distinct field names and ids and saves four distinct choices' do
    practice = practices(:practice3)
    quiz = PracticeQuiz.create!(practice:, published: false)
    login(users(:mentormentaro))
    get new_mentor_practice_practice_quiz_question_path(practice)
    assert_response :success
    fields = css_select('input[name$="[body]"]')
    assert_equal 4, fields.size
    assert_equal 4, fields.map { |field| field['name'] }.uniq.size
    assert_equal 4, fields.map { |field| field['id'] }.uniq.size

    post mentor_practice_practice_quiz_questions_path(practice), params: { practice_quiz_question: question_attributes }
    assert_redirected_to edit_mentor_practice_practice_quiz_path(practice)
    question = quiz.practice_quiz_questions.first
    get edit_mentor_practice_practice_quiz_question_path(practice, question)
    fields = css_select('input[name$="[body]"]')
    field_values = fields.map { |field| field['value'] }
    assert_equal %w[選択肢1 選択肢2 選択肢3 選択肢4], field_values
    assert_equal 4, fields.map { |field| field['id'] }.uniq.size
    attributes = question_attributes
    attributes[:practice_quiz_choices_attributes].each do |index, choice|
      choice[:id] = question.practice_quiz_choices[index.to_i].id
      choice[:body] = "更新した選択肢#{index.to_i + 1}"
    end
    patch mentor_practice_practice_quiz_question_path(practice, question), params: { practice_quiz_question: attributes }
    assert_redirected_to edit_mentor_practice_practice_quiz_path(practice)
    assert_equal (1..4).map { |index| "更新した選択肢#{index}" }, question.reload.practice_quiz_choices.map(&:body)
  end

  test 'mentor sees validation error when creating duplicate published choices' do
    practice = practices(:practice3)
    PracticeQuiz.create!(practice:, published: false)
    login(users(:mentormentaro))
    attributes = question_attributes
    attributes[:practice_quiz_choices_attributes]['1'][:body] = '選択肢1'

    assert_no_difference 'PracticeQuizQuestion.count' do
      post mentor_practice_practice_quiz_questions_path(practice), params: { practice_quiz_question: attributes }
    end
    assert_response :success
    assert_includes response.body, '公開中の問題の選択肢は重複しないようにしてください。'
  end

  test 'mentor sees validation error and persisted choices unchanged on duplicate update' do
    practice = practices(:practice3)
    quiz = PracticeQuiz.create!(practice:, published: false)
    question = quiz.practice_quiz_questions.create!(question_attributes)
    before_choices = question.practice_quiz_choices.map(&:attributes)
    login(users(:mentormentaro))

    patch mentor_practice_practice_quiz_question_path(practice, question), params: {
      practice_quiz_question: {
        practice_quiz_choices_attributes: { '1' => { id: question.practice_quiz_choices.second.id, body: '選択肢1' } }
      }
    }

    assert_response :success
    assert_includes response.body, '公開中の問題の選択肢は重複しないようにしてください。'
    assert_equal before_choices, question.reload.practice_quiz_choices.map(&:attributes)
  end

  private

  def question_attributes
    {
      question_type: 'single_choice', body: '問題文', explanation: '解説', position: 1, published: '1',
      practice_quiz_choices_attributes: (0..3).to_h do |index|
        [index.to_s, { body: "選択肢#{index + 1}", correct: index.zero? ? '1' : '0', position: index + 1 }]
      end
    }
  end

  def login(user)
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end
end
