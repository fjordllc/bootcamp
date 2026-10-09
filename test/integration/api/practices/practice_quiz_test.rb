# frozen_string_literal: true

require 'test_helper'

class API::Practices::PracticeQuizTest < ActionDispatch::IntegrationTest
  setup do
    @practice = practices(:practice1)
    @path = "/api/practices/#{@practice.id}/practice_quiz"
    @application = Doorkeeper::Application.create!(name: 'Quiz API test', redirect_uri: 'https://example.invalid/callback')
  end

  test 'mentor creates a complete draft and retrieves the same answer key' do
    payload = quiz_payload
    payload[:practice_quiz][:published] = true
    headers = oauth_headers

    assert_difference({ 'PracticeQuiz.count' => 1, 'PracticeQuizQuestion.count' => 1, 'PracticeQuizChoice.count' => 2 }) do
      post @path, params: payload, headers:, as: :json
    end

    assert_response :created
    assert_equal 'application/json', response.media_type
    quiz = @practice.reload.practice_quiz
    assert_not_predicate quiz, :published?
    expected = {
      'id' => quiz.id, 'practice_id' => @practice.id, 'published' => false,
      'questions' => [{
        'id' => quiz.practice_quiz_questions.first.id, 'question_type' => 'single_choice',
        'body' => '正しいものを選んでください。', 'explanation' => '解説です。', 'position' => 1, 'published' => true,
        'choices' => quiz.practice_quiz_questions.first.practice_quiz_choices.map do |choice|
          { 'id' => choice.id, 'body' => choice.body, 'correct' => choice.correct, 'position' => choice.position }
        end
      }]
    }
    assert_equal expected, response.parsed_body
    assert_equal [true, false], expected['questions'].first['choices'].pluck('correct')

    get @path, headers: headers

    assert_response :ok
    assert_equal expected, response.parsed_body
  end

  test 'GET requires mentor scope but does not require write scope' do
    create_quiz

    get @path, headers: oauth_headers(scopes: 'mentor')

    assert_response :ok
  end

  test 'admin without mentor role can create and show with mentor scope' do
    headers = oauth_headers(actor: :adminonly)
    post @path, params: quiz_payload, headers:, as: :json
    assert_response :created

    get @path, headers: headers
    assert_response :ok
  end

  test 'GET orders questions and choices by position then id and includes unpublished questions' do
    quiz = create_quiz
    later = quiz.practice_quiz_questions.create!(question_type: :multiple_choice, body: '後の問題', position: 2, published: false)
    earlier = quiz.practice_quiz_questions.create!(question_type: :single_choice, body: '先の問題', position: 1, published: false)
    tied = quiz.practice_quiz_questions.create!(question_type: :single_choice, body: '同じ位置の問題', position: 1, published: false)
    second = earlier.practice_quiz_choices.create!(body: '後の選択肢', correct: false, position: 2)
    first = earlier.practice_quiz_choices.create!(body: '先の選択肢', correct: true, position: 1)
    tie = earlier.practice_quiz_choices.create!(body: '同じ位置の選択肢', correct: false, position: 1)

    get @path, headers: oauth_headers

    assert_response :ok
    assert_equal [earlier.id, tied.id, later.id], response.parsed_body['questions'].pluck('id')
    assert_equal [first.id, tie.id, second.id], response.parsed_body['questions'].first['choices'].pluck('id')
    assert_not response.parsed_body['questions'].first['published']
  end

  test 'missing token cannot create or read answer keys' do
    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, as: :json }
    assert_response :unauthorized

    create_quiz
    get @path
    assert_response :unauthorized
  end

  test 'mentor session alone cannot create or read answer keys' do
    sign_in(:mentormentaro)

    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, as: :json }
    assert_response :unauthorized

    create_quiz
    get @path
    assert_response :unauthorized
  end

  test 'mentor JWT alone cannot create or read answer keys' do
    token = create_token('mentormentaro', 'testtest')
    reset!
    headers = { Authorization: "Bearer #{token}" }

    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, headers:, as: :json }
    assert_response :unauthorized

    create_quiz
    get @path, headers: headers
    assert_response :unauthorized
  end

  test 'learner OAuth token with all scopes cannot create or read answer keys' do
    headers = oauth_headers(actor: :kimura)
    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, headers:, as: :json }
    assert_response :forbidden

    create_quiz
    get @path, headers: headers
    assert_response :forbidden
  end

  test 'mentor session cannot mask learner OAuth owner' do
    headers = oauth_headers(actor: :kimura)
    sign_in(:mentormentaro)

    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, headers:, as: :json }
    assert_response :forbidden

    create_quiz
    get @path, headers: headers
    assert_response :forbidden
  end

  %w[read write mentor].each do |scopes|
    test "POST rejects token with only #{scopes} scope" do
      assert_no_difference('PracticeQuiz.count') do
        post @path, params: quiz_payload, headers: oauth_headers(scopes:), as: :json
      end
      assert_response :forbidden
      assert_equal 'invalid_scope', response.parsed_body['error']
    end
  end

  test 'GET rejects OAuth token without mentor scope' do
    create_quiz
    get @path, headers: oauth_headers(scopes: 'read write')
    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'inactive mentor cannot create or read answer keys' do
    headers = oauth_headers
    users(:mentormentaro).update!(retired_on: Date.current)

    assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, headers:, as: :json }
    assert_response :unauthorized

    create_quiz
    get @path, headers: headers
    assert_response :unauthorized
  end

  test 'expired and revoked OAuth tokens cannot read or create' do
    [{ expires_in: 1, created_at: 2.minutes.ago }, { revoked_at: Time.current }].each do |attributes|
      headers = oauth_headers(**attributes)
      assert_no_difference('PracticeQuiz.count') { post @path, params: quiz_payload, headers:, as: :json }
      assert_response :unauthorized
      get @path, headers: headers
      assert_response :unauthorized
    end
  end

  test 'invalid later question rolls back quiz questions and choices' do
    payload = quiz_payload
    invalid_question = payload[:practice_quiz][:practice_quiz_questions_attributes].first.deep_dup
    invalid_question[:body] = ''
    payload[:practice_quiz][:practice_quiz_questions_attributes] << invalid_question

    assert_no_quiz_created(payload)
  end

  test 'invalid enum returns validation errors without creating quiz' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:question_type] = 'unknown'

    assert_no_quiz_created(payload)
  end

  test 'invalid choice position rolls back the complete quiz' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:practice_quiz_choices_attributes].first[:position] = nil

    assert_no_quiz_created(payload)
  end

  test 'single choice question rejects multiple correct choices' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:practice_quiz_choices_attributes].last[:correct] = true

    assert_no_quiz_created(payload)
  end

  test 'POST requires at least one question' do
    assert_no_quiz_created(practice_quiz: { practice_quiz_questions_attributes: [] })
  end

  test 'unpublished question must still have a complete choice set' do
    payload = quiz_payload
    question = payload[:practice_quiz][:practice_quiz_questions_attributes].first
    question[:published] = false
    question[:practice_quiz_choices_attributes] = [{ body: '正解', correct: true, position: 1 }]

    assert_no_quiz_created(payload)
  end

  test 'unpublished valid question keeps its published flag' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:published] = false

    post @path, params: payload, headers: oauth_headers, as: :json

    assert_response :created
    assert_not response.parsed_body['questions'].first['published']
  end

  test 'blank choice body cannot be silently dropped from a valid choice set' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:practice_quiz_choices_attributes] << { body: ' ', correct: false, position: 3 }

    assert_no_quiz_created(payload)
  end

  test 'multiple choice question requires a correct answer' do
    payload = quiz_payload
    question = payload[:practice_quiz][:practice_quiz_questions_attributes].first
    question[:question_type] = 'multiple_choice'
    question[:published] = false
    question[:practice_quiz_choices_attributes].each { |choice| choice[:correct] = false }

    assert_no_quiz_created(payload)
  end

  test 'multiple choice question accepts multiple correct answers' do
    payload = quiz_payload
    question = payload[:practice_quiz][:practice_quiz_questions_attributes].first
    question[:question_type] = 'multiple_choice'
    question[:practice_quiz_choices_attributes].each { |choice| choice[:correct] = true }

    post @path, params: payload, headers: oauth_headers, as: :json

    assert_response :created
    assert_equal [true, true], response.parsed_body['questions'].first['choices'].pluck('correct')
  end

  test 'malformed payloads return 422 without creating rows' do
    [
      {},
      { practice_quiz: 'invalid' },
      { practice_quiz: { practice_quiz_questions_attributes: 'invalid' } },
      { practice_quiz: { practice_quiz_questions_attributes: ['invalid'] } }
    ].each { |payload| assert_no_quiz_created(payload) }
  end

  test 'missing question type returns 422 without creating rows' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first.delete(:question_type)

    assert_no_quiz_created(payload)
  end

  test 'null published or correct flags return 422 without database errors' do
    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:published] = nil
    assert_no_quiz_created(payload)

    payload = quiz_payload
    payload[:practice_quiz][:practice_quiz_questions_attributes].first[:practice_quiz_choices_attributes].first[:correct] = nil
    assert_no_quiz_created(payload)
  end

  test 'duplicate POST does not change existing quiz or questions' do
    headers = oauth_headers
    post @path, params: quiz_payload, headers:, as: :json
    assert_response :created
    original = response.parsed_body

    assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
      post @path, params: quiz_payload, headers:, as: :json
    end
    assert_response :conflict

    get @path, headers: headers
    assert_response :ok
    assert_equal original, response.parsed_body
  end

  test 'uniqueness validation handles a quiz created after the initial existence check' do
    original = create_quiz

    PracticeQuiz.stub(:exists?, false) do
      assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
        post @path, params: quiz_payload, headers: oauth_headers, as: :json
      end
    end

    assert_response :conflict
    assert_equal original, @practice.reload.practice_quiz
  end

  test 'database uniqueness conflict returns 409 without saving nested rows' do
    quiz = PracticeQuiz.new(practice: @practice, published: false, **quiz_payload[:practice_quiz])

    PracticeQuiz.stub(:new, quiz) do
      quiz.stub(:save, -> { raise ActiveRecord::RecordNotUnique }) do
        assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
          post @path, params: quiz_payload, headers: oauth_headers, as: :json
        end
      end
    end

    assert_response :conflict
  end

  test 'missing practice returns 404 for GET and POST' do
    path = '/api/practices/0/practice_quiz'
    headers = oauth_headers
    get path, headers: headers
    assert_response :not_found

    assert_no_difference('PracticeQuiz.count') { post path, params: quiz_payload, headers:, as: :json }
    assert_response :not_found
  end

  test 'GET returns 404 when practice has no quiz' do
    get @path, headers: oauth_headers
    assert_response :not_found
  end

  test 'mentor updates publication question fields and choice fields with PATCH and PUT' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    choices = question.practice_quiz_choices.to_a
    attempt = quiz.practice_quiz_attempts.create!(user: users(:kimura), submitted_at: Time.current)
    answer = attempt.practice_quiz_answers.create!(practice_quiz_choice: choices.first, correct: true)

    %i[patch put].each do |method|
      public_send(method, @path, params: { practice_quiz: {
                    published: true, practice_quiz_questions_attributes: [{
                      id: question.id, body: "#{method}の問題", explanation: '更新した解説', position: 2,
                      question_type: 'multiple_choice', practice_quiz_choices_attributes: [{ id: choices.last.id, correct: true, position: 3 }]
                    }]
                  } }, headers: oauth_headers, as: :json)

      assert_response :ok
      assert response.parsed_body['published']
      assert_equal "#{method}の問題", question.reload.body
      assert_equal '更新した解説', question.explanation
      assert_equal 2, question.position
      assert_equal 'multiple_choice', question.question_type
      assert_predicate choices.last.reload, :correct?
      assert_equal 3, choices.last.position
      assert_equal '不正解', choices.last.body
      assert_equal answer.attributes, answer.reload.attributes
      assert_equal attempt.attributes, attempt.reload.attributes
    end
  end

  test 'PATCH preserves unspecified nested rows and publication flags' do
    quiz = create_complete_quiz
    quiz.update!(published: true)
    question = quiz.practice_quiz_questions.first
    choices = question.practice_quiz_choices.map(&:attributes)

    patch @path, params: { practice_quiz: { practice_quiz_questions_attributes: [{ id: question.id, explanation: '解説のみ更新' }] } }, headers: oauth_headers,
                 as: :json

    assert_response :ok
    assert_predicate quiz.reload, :published?
    assert_predicate question.reload, :published?
    assert_equal '正しいものを選んでください。', question.body
    assert_equal choices, question.practice_quiz_choices.reload.map(&:attributes)
  end

  test 'PATCH adds questions and choices and removes only specified rows' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    removed_choice = question.practice_quiz_choices.last
    added_question = quiz_payload[:practice_quiz][:practice_quiz_questions_attributes].first.deep_dup
    added_question[:body] = '追加の問題'

    patch @path, params: { practice_quiz: { practice_quiz_questions_attributes: [
      { id: question.id, practice_quiz_choices_attributes: [{ id: removed_choice.id, _destroy: true }, { body: '新しい不正解', correct: false, position: 2 }] },
      added_question
    ] } }, headers: oauth_headers, as: :json

    assert_response :ok
    assert_not PracticeQuizChoice.exists?(removed_choice.id)
    assert_equal 2, quiz.practice_quiz_questions.reload.count
    added = quiz.practice_quiz_questions.find_by!(body: '追加の問題')
    assert_predicate added, :published?
    assert_equal %w[正解 新しい不正解], question.practice_quiz_choices.reload.pluck(:body)

    patch @path, params: { practice_quiz: { practice_quiz_questions_attributes: [{ id: added.id, _destroy: true }] } }, headers: oauth_headers, as: :json

    assert_response :ok
    assert_not PracticeQuizQuestion.exists?(added.id)
    assert_equal [question.id], quiz.practice_quiz_questions.reload.pluck(:id)
  end

  test 'PATCH publishes and unpublishes the quiz explicitly' do
    quiz = create_complete_quiz
    [true, false].each do |published|
      patch @path, params: { practice_quiz: { published: } }, headers: oauth_headers, as: :json
      assert_response :ok
      assert_equal published, quiz.reload.published
    end
  end

  test 'PATCH cannot publish a quiz without a published question' do
    quiz = create_quiz
    assert_update_rejected(quiz, published: true)
  end

  test 'PATCH validates resulting publication when all questions are removed or unpublished' do
    quiz = create_complete_quiz
    quiz.update!(published: true)
    question = quiz.practice_quiz_questions.first
    [{ _destroy: true }, { published: false }].each do |attributes|
      assert_update_rejected(quiz, practice_quiz_questions_attributes: [{ id: question.id, **attributes }])
    end
  end

  test 'PATCH can replace the last published question atomically' do
    quiz = create_complete_quiz
    quiz.update!(published: true)
    old_question = quiz.practice_quiz_questions.first
    new_question = quiz_payload[:practice_quiz][:practice_quiz_questions_attributes].first.deep_dup
    new_question[:body] = '置き換えた問題'

    patch @path, params: { practice_quiz: { practice_quiz_questions_attributes: [{ id: old_question.id, _destroy: true }, new_question] } },
                 headers: oauth_headers, as: :json

    assert_response :ok
    assert_predicate quiz.reload, :published?
    assert_not PracticeQuizQuestion.exists?(old_question.id)
    assert_equal ['置き換えた問題'], quiz.practice_quiz_questions.pluck(:body)
  end

  test 'invalid nested update rolls back publication and earlier choice changes' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    choices = question.practice_quiz_choices.to_a
    assert_update_rejected(quiz, published: true, practice_quiz_questions_attributes: [{
                             id: question.id, body: '', practice_quiz_choices_attributes: [{ id: choices.first.id, body: '保存されない本文' }]
                           }])
  end

  test 'unpublished questions still require complete choice sets after update' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    assert_update_rejected(quiz, practice_quiz_questions_attributes: [{
                             id: question.id, published: false,
                             practice_quiz_choices_attributes: [{ id: question.practice_quiz_choices.last.id, _destroy: true }]
                           }])
  end

  test 'PATCH rejects invalid correct answer sets' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    question.practice_quiz_choices.each do |choice|
      assert_update_rejected(quiz,
                             practice_quiz_questions_attributes: [{ id: question.id,
                                                                    practice_quiz_choices_attributes: [{ id: choice.id, correct: !choice.correct }] }])
    end
  end

  test 'PATCH cannot remove a choice referenced by an answer' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    choice = question.practice_quiz_choices.last
    attempt = quiz.practice_quiz_attempts.create!(user: users(:kimura), submitted_at: Time.current)
    answer = attempt.practice_quiz_answers.create!(practice_quiz_choice: choice, correct: false)
    assert_update_rejected(quiz, published: true, practice_quiz_questions_attributes: [{
                             id: question.id, body: '保存されない問題',
                             practice_quiz_choices_attributes: [{ id: choice.id, _destroy: true }, { body: '新しい選択肢', correct: false }]
                           }])
    assert PracticeQuizAttempt.exists?(attempt.id)
    assert PracticeQuizAnswer.exists?(answer.id)
  end

  test 'PATCH rejects foreign and unknown nested IDs without changing either quiz' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    other = PracticeQuiz.create!(practice: practices(:practice2), published: false, **quiz_payload[:practice_quiz])
    other_question = other.practice_quiz_questions.first
    [other_question.id, 0].each do |id|
      assert_update_rejected(quiz, published: true, practice_quiz_questions_attributes: [{ id:, body: '変更されない本文' }], statuses: [404, 422])
    end
    [other_question.practice_quiz_choices.first.id, 0].each do |id|
      assert_update_rejected(quiz, published: true, statuses: [404, 422], practice_quiz_questions_attributes: [{
                               id: question.id, practice_quiz_choices_attributes: [{ id:, body: '変更されない本文' }]
                             }])
    end
    assert_equal '正しいものを選んでください。', other_question.reload.body
    assert_equal '正解', other_question.practice_quiz_choices.first.body
  end

  test 'PATCH cannot remove a question whose choice is referenced by an answer' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    attempt = quiz.practice_quiz_attempts.create!(user: users(:kimura), submitted_at: Time.current)
    answer = attempt.practice_quiz_answers.create!(practice_quiz_choice: question.practice_quiz_choices.last, correct: false)

    assert_update_rejected(quiz, practice_quiz_questions_attributes: [{ id: question.id, _destroy: true }])

    assert_equal answer.attributes, answer.reload.attributes
    assert_equal attempt.attributes, attempt.reload.attributes
  end

  test 'PATCH accepts omitted question attributes without changing nested rows' do
    quiz = create_complete_quiz
    before = quiz_snapshot(quiz).last

    patch @path, params: { practice_quiz: {} }, headers: oauth_headers, as: :json

    assert_response :ok
    assert_equal before, quiz_snapshot(quiz).last
    assert_not_predicate quiz.reload, :published?
  end

  test 'PATCH rejects empty question arrays without changing publication or nested rows' do
    quiz = create_complete_quiz

    assert_update_rejected(quiz, published: true, practice_quiz_questions_attributes: [])

    assert response.parsed_body['errors'].present?
  end

  test 'PATCH rejects empty choice arrays without changing publication or nested rows' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first

    assert_update_rejected(quiz, published: true, practice_quiz_questions_attributes: [{
                             id: question.id, body: '保存されない本文', practice_quiz_choices_attributes: []
                           }])

    assert response.parsed_body['errors'].present?
  end

  test 'PATCH rejects malformed arrays flags enum and blank choices' do
    quiz = create_complete_quiz
    question = quiz.practice_quiz_questions.first
    [nil, 'true', 1, [], {}].each { |published| assert_update_rejected(quiz, published:) }
    ['invalid', {}, [nil]].each { |questions| assert_update_rejected(quiz, practice_quiz_questions_attributes: questions) }
    [
      { published: 'false' }, { _destroy: 'true' }, { question_type: 'unknown' },
      { practice_quiz_choices_attributes: 'invalid' }, { practice_quiz_choices_attributes: {} },
      { practice_quiz_choices_attributes: [nil] },
      { practice_quiz_choices_attributes: [{ id: question.practice_quiz_choices.first.id, body: ' ' }] },
      { practice_quiz_choices_attributes: [{ id: question.practice_quiz_choices.first.id, correct: nil }] },
      { practice_quiz_choices_attributes: [{ id: question.practice_quiz_choices.first.id, _destroy: 1 }] },
      { practice_quiz_choices_attributes: [{ body: '', correct: false }] }
    ].each { |attributes| assert_update_rejected(quiz, practice_quiz_questions_attributes: [{ id: question.id, **attributes }]) }
    [{}, { practice_quiz: nil }, { practice_quiz: 'invalid' }].each do |payload|
      patch @path, params: payload, headers: oauth_headers, as: :json
      assert_response :unprocessable_entity
    end
  end

  %i[patch put delete].each do |method|
    test "#{method} requires mentor and write scopes" do
      quiz = create_complete_quiz
      ['mentor', 'write', 'read write'].each do |scopes|
        public_send(method, @path, params: { practice_quiz: { published: true } }, headers: oauth_headers(scopes:), as: :json)
        assert_response :forbidden
        assert_equal 'invalid_scope', response.parsed_body['error']
        assert_not_predicate quiz.reload, :published?
      end
    end

    test "#{method} rejects absent tokens learner owners and session authorization" do
      quiz = create_complete_quiz
      sign_in(:mentormentaro)
      [nil, oauth_headers(actor: :kimura)].each do |headers|
        public_send(method, @path, params: { practice_quiz: { published: true } }, headers: headers, as: :json)
        assert_response(headers ? :forbidden : :unauthorized)
        assert_not_predicate quiz.reload, :published?
        assert_not response.parsed_body.key?('questions')
      end
    end

    test "#{method} returns 404 for missing quiz and missing practice" do
      [@path, '/api/practices/0/practice_quiz'].each do |path|
        public_send(method, path, params: { practice_quiz: { published: true } }, headers: oauth_headers, as: :json)
        assert_response :not_found
      end
    end
  end

  test 'DELETE removes a draft quiz and its nested rows and subsequent GET is 404' do
    create_complete_quiz
    headers = oauth_headers
    assert_difference({ 'PracticeQuiz.count' => -1, 'PracticeQuizQuestion.count' => -1, 'PracticeQuizChoice.count' => -2 }) do
      delete @path, headers: headers
    end
    assert_response :no_content
    assert_empty response.body
    get @path, headers: headers
    assert_response :not_found
  end

  test 'DELETE removes an attempt-free published quiz' do
    quiz = create_complete_quiz
    quiz.update!(published: true)

    delete @path, headers: oauth_headers

    assert_response :no_content
    assert_not PracticeQuiz.exists?(quiz.id)
  end

  test 'DELETE returns 409 and preserves quiz and learner history when attempts exist' do
    quiz = create_complete_quiz
    quiz.update!(published: true)
    attempt = quiz.practice_quiz_attempts.create!(user: users(:kimura), submitted_at: Time.current)
    answer = attempt.practice_quiz_answers.create!(practice_quiz_choice: quiz.practice_quiz_questions.first.practice_quiz_choices.first, correct: true)
    before = quiz_snapshot(quiz)

    assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count', 'PracticeQuizAttempt.count',
                          'PracticeQuizAnswer.count']) do
      delete @path, headers: oauth_headers
    end

    assert_response :conflict
    assert response.parsed_body['message'].present?
    assert_equal before, quiz_snapshot(quiz)
    assert_equal answer.attributes, answer.reload.attributes
    assert_equal attempt.attributes, attempt.reload.attributes
  end

  test 'DELETE rolls back unpublishing and nested rows when a destroy callback refuses' do
    quiz = create_complete_quiz
    quiz.update!(published: true)
    before = quiz_snapshot(quiz)
    callback = lambda do |question|
      next unless question.practice_quiz_id == quiz.id

      question.errors.add(:base, '削除を拒否しました。')
      throw :abort
    end
    PracticeQuizQuestion.set_callback(:destroy, :before, callback, prepend: true)

    assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
      delete @path, headers: oauth_headers
    end

    assert_response :unprocessable_entity
    assert_equal before, quiz_snapshot(quiz)
  ensure
    PracticeQuizQuestion.skip_callback(:destroy, :before, callback) if callback
  end

  private

  def oauth_headers(actor: :mentormentaro, scopes: 'write mentor', **attributes)
    token = Doorkeeper::AccessToken.create!(application: @application, resource_owner_id: users(actor).id, scopes:, **attributes)
    { Authorization: "Bearer #{token.token}" }
  end

  def quiz_payload
    {
      practice_quiz: {
        practice_quiz_questions_attributes: [{
          question_type: 'single_choice', body: '正しいものを選んでください。', explanation: '解説です。', position: 1,
          practice_quiz_choices_attributes: [
            { body: '正解', correct: true, position: 1 },
            { body: '不正解', correct: false, position: 2 }
          ]
        }]
      }
    }
  end

  def create_complete_quiz
    PracticeQuiz.create!(practice: @practice, published: false, **quiz_payload[:practice_quiz].deep_merge(
      practice_quiz_questions_attributes: quiz_payload[:practice_quiz][:practice_quiz_questions_attributes].map { |question| question.merge(published: true) }
    ))
  end

  def assert_update_rejected(quiz, statuses: [422], **attributes)
    before = quiz_snapshot(quiz)
    assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
      patch @path, params: { practice_quiz: attributes }, headers: oauth_headers, as: :json
    end
    assert_includes statuses, response.status
    assert_equal before, quiz_snapshot(quiz)
  end

  def quiz_snapshot(quiz)
    [quiz.reload.attributes, quiz.practice_quiz_questions.reload.map do |question|
      [question.attributes, question.practice_quiz_choices.map(&:attributes)]
    end]
  end

  def create_quiz
    PracticeQuiz.create!(practice: @practice, published: false)
  end

  def assert_no_quiz_created(payload)
    assert_no_difference(['PracticeQuiz.count', 'PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
      post @path, params: payload, headers: oauth_headers, as: :json
    end
    assert_response :unprocessable_entity
    assert response.parsed_body['errors'].present?
  end
end
