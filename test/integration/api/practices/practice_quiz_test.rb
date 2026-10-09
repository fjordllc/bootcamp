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
