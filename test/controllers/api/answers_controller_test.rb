# frozen_string_literal: true

require 'test_helper'

class API::AnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

  test 'GET /api/answers.json?user_id=253826460' do
    user = users(:hajime)
    get api_answers_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_answers_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'POST /api/answers.json with read scope returns forbidden' do
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:hajime).id,
      scopes: 'read'
    )

    post api_answers_path(format: :json),
         params: { question_id: questions(:question1).id, answer: { description: '回答します。' } },
         headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'create appends an answer and replaces the count and form' do
    sign_in(:hajime)
    question = questions(:question2)
    count = question.answers.count

    assert_difference -> { question.answers.count }, 1 do
      post api_answers_path, params: { question_id: question.id, answer: { description: '回答します。' } }, as: :turbo_stream
    end

    assert_response :created
    answer = question.answers.order(:id).last
    assert_turbo_stream(status: :created, action: 'append', target: dom_id(question, :answers)) do
      assert_select "template #answer_#{answer.id}[data-controller='answer']"
    end
    assert_turbo_stream(status: :created, action: 'replace', target: dom_id(question, :answer_count)) do
      assert_select 'template .js-answer-count', text: (count + 1).to_s
    end
    assert_turbo_stream(status: :created, action: 'replace', target: dom_id(question, :new_answer)) do
      assert_select 'template form[data-turbo=true]'
      assert_select 'template textarea', text: ''
    end
  end

  test 'invalid create keeps the input and only replaces the form' do
    sign_in(:hajime)
    question = questions(:question2)
    description = " \n "

    assert_no_difference -> { Answer.count } do
      post api_answers_path, params: { question_id: question.id, answer: { description: } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_select 'turbo-stream', count: 1
    assert_turbo_stream(status: :unprocessable_entity, action: 'replace', target: dom_id(question, :new_answer)) do
      assert_select 'template textarea' do |elements|
        assert_equal description, elements.first.content
      end
      assert_select 'template .errors'
    end
  end

  test 'create preserves the JSON response' do
    sign_in(:hajime)
    question = questions(:question2)

    assert_difference -> { Answer.count }, 1 do
      post api_answers_path, params: { question_id: question.id, answer: { description: 'JSONの回答' } }, as: :json
    end

    assert_response :created
    assert_equal 'JSONの回答', response.parsed_body['description']
    assert_equal question.id, response.parsed_body['question_id']
    assert_equal users(:hajime).id, response.parsed_body.dig('user', 'id')
  end

  test 'invalid JSON create preserves validation errors' do
    sign_in(:hajime)
    assert_no_difference -> { Answer.count } do
      post api_answers_path, params: { question_id: questions(:question2).id, answer: { description: '' } }, as: :json
    end
    assert_response :unprocessable_entity
    assert response.parsed_body['errors']['description'].present?
  end

  test 'create requires authentication for Turbo Stream requests' do
    assert_no_difference -> { Answer.count } do
      post api_answers_path, params: { question_id: questions(:question2).id, answer: { description: '回答' } }, as: :turbo_stream
    end
    assert_response :unauthorized
  end

  test 'HTML create redirects to the saved answer' do
    sign_in(:hajime)
    question = questions(:question2)

    assert_difference -> { Answer.count }, 1 do
      post api_answers_path, params: { question_id: question.id, answer: { description: 'HTMLで投稿した回答' } }
    end

    answer = question.answers.order(:id).last
    assert_response :see_other
    assert_redirected_to question_path(question, anchor: "answer_#{answer.id}")
    assert_equal '回答を投稿しました！', flash[:notice]
    follow_redirect!
    assert_response :success
    assert_select "#answer_#{answer.id} .answer-text", text: 'HTMLで投稿した回答'
  end

  test 'invalid HTML create renders the question with the input and errors' do
    sign_in(:hajime)
    question = questions(:question2)
    description = " \n "

    assert_no_difference -> { Answer.count } do
      post api_answers_path, params: { question_id: question.id, answer: { description: } }
    end

    assert_response :unprocessable_entity
    assert_equal 'text/html', response.media_type
    assert_select '.page-content-header__title', text: /#{Regexp.escape(question.title)}/
    assert_select '.new-answer .errors'
    assert_select '.new-answer textarea' do |elements|
      assert_equal description, elements.first.content
    end
    assert_select '.answers-list .answer', count: question.answers.count
    assert_select '.a-side-nav__body'
    assert_select '.new-answer form[action=?]', api_answers_path
    assert_select '.new-answer input[name="question_id"][value=?]', question.id.to_s
  end
end
