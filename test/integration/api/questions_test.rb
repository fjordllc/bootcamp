# frozen_string_literal: true

require 'test_helper'

class Api::QuestionsTest < ActionDispatch::IntegrationTest
  fixtures :questions

  setup do
    @question = questions(:question8)
    @path = api_question_path(@question.id, format: :json)
    @non_editable_user_login_name = User.where.not(login_name: @question.user.login_name)
                                        .find_by(admin: false).login_name
  end

  test 'GET api/questions.json' do
    get @path
    assert_response :unauthorized

    [@question.user.login_name, @non_editable_user_login_name].each do |name|
      token = create_token(name, 'testtest')
      get @path, headers: { 'Authorization' => "Bearer #{token}" }

      assert_response :ok
    end
  end

  test 'UPDATE api/questions.json' do
    patch @path, params: { question: { title: '認証失敗' } }
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    patch @path,
          params: { question: { tag_list: '新規タグ1,新規タグ2' } },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
    assert_equal %w[新規タグ1 新規タグ2], @question.reload.tag_list
  end

  test 'GET /api/questions.json?user_id=253826460' do
    user = users(:hajime)
    get api_questions_path(user_id: user.id, format: :json)
    assert_response :unauthorized

    token = create_token('hajime', 'testtest')
    get api_questions_path(user_id: user.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
