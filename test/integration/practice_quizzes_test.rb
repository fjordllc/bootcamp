# frozen_string_literal: true

require 'test_helper'

class PracticeQuizzesTest < ActionDispatch::IntegrationTest
  test 'guest can view practice without quiz management tab' do
    practice = practices(:practice3)

    get practice_path(practice)

    assert_response :success
    assert_not_includes response.body, '理解度テスト管理'
  end

  test 'student passes five questions and automatically completes practice' do
    user = users(:kimura)
    practice = practices(:practice3)
    quiz, question = create_quiz(practice)
    questions = [question] + (2..5).map { |position| create_question(quiz, position:) }
    login(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :unprocessable_entity
    assert_equal '理解度テストに合格すると、このプラクティスを修了できます。', response.parsed_body['error']

    post practice_practice_quiz_attempts_path(practice), params: {
      answers: {
        **questions.to_h { |item| [item.id, item.correct_choice_ids] }
      }
    }

    assert_redirected_to practice_practice_quiz_path(practice)
    follow_redirect!
    assert_response :success
    assert_includes response.body, '理解度テストに合格しました。'
    assert_includes response.body, '正しい選択肢'
    assert_includes response.body, '解説です。'
    assert quiz.passed_by?(user)
    assert Learning.find_by!(user:, practice:).complete?
    assert_includes response.body, 'このプラクティスを修了しました。'
    assert_equal 5, quiz.practice_quiz_attempts.last.practice_quiz_answers.count

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :success
    assert Learning.find_by!(user:, practice:).complete?

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a[href=?]', practice_practice_quiz_path(practice), text: '理解度テストの解説を見る'
    assert_select next_step, 'button.test-completed', text: '修了しています', count: 1
    assert_select '#js-complete', count: 0
  end

  test 'student can complete practice without quiz as before' do
    user = users(:kimura)
    practice = practices(:practice4)
    login(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }

    assert_response :success
    assert Learning.find_by!(user:, practice:).complete?
  end

  test 'student receives unprocessable entity when learning status is invalid' do
    user = users(:kimura)
    practice = practices(:practice4)
    login(user)

    patch api_practice_learning_path(practice, format: :json), params: { status: 'invalid' }

    assert_response :unprocessable_entity
    assert_equal 'status is invalid', response.parsed_body['error']
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
    assert_not Learning.find_by(user:, practice:)&.complete?

    assert_no_difference 'PracticeQuizAttempt.count' do
      post practice_practice_quiz_attempts_path(practice), params: {
        answers: {
          question.id => [question.practice_quiz_choices.find_by!(correct: true).id]
        }
      }
    end
    assert_redirected_to practice_practice_quiz_path(practice)
    follow_redirect!
    assert_includes response.body, '次回は'
    assert_not_includes response.body, '正しい選択肢'
    assert_includes response.body, '間違えた問題を復習'
    assert_includes response.body, '解説です。'
    assert_select 'a[href=?]', practice_path(practice), text: '本文を読み直す'
  end

  test 'student can pass multiple choice quiz' do
    user = users(:kimura)
    practice = practices(:practice3)
    _quiz, question = create_quiz(practice, question_type: :multiple_choice)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: {
      answers: {
        question.id => question.practice_quiz_choices.where(correct: true).pluck(:id)
      }
    }

    assert_redirected_to practice_practice_quiz_path(practice)
    follow_redirect!
    assert_response :success
    assert_includes response.body, '理解度テストに合格しました。'
  end

  test 'failed quiz shows explanations only for incorrect questions' do
    user = users(:kimura)
    practice = practices(:practice3)
    quiz, first_question = create_quiz(practice)
    second_question = create_question(quiz, position: 2)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: {
      answers: {
        first_question.id => first_question.correct_choice_ids,
        second_question.id => [second_question.practice_quiz_choices.find_by!(correct: false).id]
      }
    }
    follow_redirect!

    assert_select 'h2.card-header__title', text: '間違えた問題を復習'
    assert_select 'h3', text: '問2', count: 1
    assert_select 'h3', text: '問1', count: 0
    assert_not Learning.find_by(user:, practice:)&.complete?
  end

  test 'passing quiz for submission practice still requires checked product' do
    user = users(:hajime)
    practice = practices(:practice1)
    quiz, question = create_quiz(practice)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: { answers: { question.id => question.correct_choice_ids } }

    assert_redirected_to practice_practice_quiz_path(practice)
    assert quiz.passed_by?(user)
    assert_not Learning.find_by(user:, practice:)&.complete?
    patch api_practice_learning_path(practice, format: :json), params: { status: 'complete' }
    assert_response :unprocessable_entity
    follow_redirect! if response.redirect?
    get practice_practice_quiz_path(practice)
    assert_includes response.body, '提出物の確認をもらってから修了にしてください。'

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a.test-product', text: '提出物を作る', count: 1
    assert_select next_step, '#js-complete, .test-completed', count: 0
    assert_includes response.body, '理解度テストに合格済みです。提出物を作成してください。'
    assert_operator next_step.to_html.index('理解度テストの解説を見る'), :<, next_step.to_html.index('提出物を作る')
  end

  test 'passed quiz shows completion action after product is checked' do
    user = users(:kimura)
    practice = practices(:practice1)
    quiz, question = create_quiz(practice)
    Learning.find_by!(user:, practice:).update!(status: :started)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: { answers: { question.id => question.correct_choice_ids } }

    assert quiz.passed_by?(user)
    assert practice.completable_by?(user)
    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a.test-product', text: '提出物へ', count: 1
    assert_select next_step, '#js-complete', count: 1
  end

  test 'completed learning remains complete after quiz failure visit and retry' do
    user = users(:kimura)
    practice = practices(:practice3)
    _quiz, question = create_quiz(practice)
    learning = Learning.find_or_initialize_by(user:, practice:)
    learning.update!(status: :complete)
    login(user)

    post practice_practice_quiz_attempts_path(practice), params: { answers: {} }
    assert learning.reload.complete?
    get practice_practice_quiz_path(practice)
    assert learning.reload.complete?
    travel 1.hour do
      post practice_practice_quiz_attempts_path(practice), params: { answers: { question.id => question.correct_choice_ids } }
    end
    assert learning.reload.complete?
    assert_no_difference 'PracticeQuizAttempt.count' do
      post practice_practice_quiz_attempts_path(practice), params: { answers: {} }
    end
    assert learning.reload.complete?
  end

  test 'quiz goal precedes article with primary quiz action before question action' do
    practice = practices(:practice3)
    create_quiz(practice)
    login(users(:kimura))

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_includes response.body, '本文を読み、理解度テストに全問正解すると自動で修了になります。'
    assert_select next_step, 'a.a-button.is-primary.is-block[href=?]', practice_practice_quiz_path(practice), text: '理解度テストに進む'
    assert_select '#js-complete', count: 0
    assert_operator response.body.index('理解度テストに進む'), :<, response.body.index('質問する')
    assert_select '.practice-status-buttons__item button.js-complete[disabled]', text: '修了'
  end

  test 'submission practice with unpassed quiz shows product but not completion action' do
    practice = practices(:practice1)
    create_quiz(practice)
    login(users(:hajime))

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a.test-product', text: '提出物を作る', count: 1
    assert_select next_step, '#js-complete, .test-completed', count: 0
    assert_includes response.body, '本文を読んだら理解度テストに進んでください。'
  end

  test 'submission practice has product and completion actions after article' do
    practice = practices(:practice1)
    login(users(:hajime))

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a.test-product[href=?]', new_product_path(practice_id: practice.id), text: '提出物を作る'
    assert_select next_step, '#js-complete', count: 1
    assert_select '.practice.page-content a.test-product', count: 1
    assert_select '#js-complete', count: 1
    assert_includes response.body, '提出の前に、提出時の注意点を確認しよう'
  end

  test 'submission practice keeps link to existing product in next step' do
    practice = practices(:practice1)
    user = users(:kimura)
    login(user)

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a.test-product[href=?]', product_path(practice.product(user)), text: '提出物へ'
  end

  test 'practice without submission has completion action after article' do
    practice = practices(:practice4)
    login(users(:hajime))

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, '#js-complete[data-practice-id=?]', practice.id, text: '修了', count: 1
    assert_select '#js-complete', count: 1
    assert_select '.practice.page-content a.test-product', count: 0
  end

  test 'skipped practice keeps question action without goal or next step' do
    practice = practices(:practice5)
    login(users(:kensyu))

    get practice_path(practice)

    assert_response :success
    assert_skipped_reading_flow(practice)
  end

  test 'skipped quiz practice keeps question action without goal or next step' do
    practice = practices(:practice5)
    create_quiz(practice)
    login(users(:kensyu))

    get practice_path(practice)

    assert_response :success
    assert_skipped_reading_flow(practice)
  end

  test 'grant course guidance remains in next step without product or completion actions' do
    practice = practices(:practice23)
    login(users(:'grant-course'))

    get practice_path(practice)

    assert_response :success
    next_step = assert_reading_flow(practice)
    assert_select next_step, 'a[href=?]', practice_path(practices(:practice64)), text: '給付金コースへ移動する'
    assert_includes next_step.text, '提出・修了は、給付金コースのプラクティス側で行ってください。'
    assert_select '.practice.page-content a.test-product, #js-complete', count: 0
    assert_not_includes response.body, '提出の前に、提出時の注意点を確認しよう'
  end

  private

  def assert_reading_flow(practice)
    cards = css_select('.practice.page-content > section.a-card')
    titles = cards.map { |card| card.at_css('h2.card-header__title').text.strip }
    goal_title = Practice.human_attribute_name(:goal)
    article_title = Practice.human_attribute_name(:description)
    assert_equal 1, titles.count(goal_title)
    assert_equal 1, titles.count('次にやること')
    assert_operator titles.index(goal_title), :<, titles.index(article_title)
    assert_operator titles.index(article_title), :<, titles.index('次にやること')
    assert_operator titles.index('参考書籍'), :<, titles.index('次にやること') if titles.include?('参考書籍')
    assert_operator titles.index('コーディングテスト'), :<, titles.index('次にやること') if titles.include?('コーディングテスト')
    goal = cards[titles.index(goal_title)]
    assert_empty goal.css('a.test-product, #js-complete, .test-completed')
    next_step = cards[titles.index('次にやること')]
    assert_select next_step, 'a.a-button.is-secondary[href=?]', new_question_path(practice_id: practice.id), text: '質問する', count: 1
    assert_select '.practice.page-content a[href=?]', new_question_path(practice_id: practice.id), count: 1
    next_step
  end

  def assert_skipped_reading_flow(practice)
    assert_select 'h2.card-header__title', text: Practice.human_attribute_name(:goal), count: 0
    assert_select 'h2.card-header__title', text: '次にやること', count: 0
    assert_select 'a[href=?]', new_question_path(practice_id: practice.id), text: '質問する', count: 1
  end

  def login(user)
    post user_sessions_path, params: {
      user: {
        login: user.login_name,
        password: 'testtest'
      }
    }
  end

  def create_quiz(practice, question_type: :single_choice)
    quiz = PracticeQuiz.create!(practice:, published: false)
    question = create_question(quiz, question_type:)
    quiz.update!(published: true)
    [quiz, question]
  end

  def create_question(quiz, question_type: :single_choice, position: 1)
    question = quiz.practice_quiz_questions.create!(
      question_type:,
      body: '正しいものを選んでください。',
      explanation: '解説です。',
      position:,
      published: false
    )
    question.practice_quiz_choices.create!(body: '正しい選択肢', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: 'もう一つの正しい選択肢', correct: true, position: 2) if question.multiple_choice?
    question.practice_quiz_choices.create!(body: '誤った選択肢', correct: false, position: 3)
    question.update!(published: true)
    question
  end
end
