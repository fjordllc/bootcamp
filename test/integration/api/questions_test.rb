# frozen_string_literal: true

require 'test_helper'

class API::QuestionsTest < ActionDispatch::IntegrationTest
  fixtures :questions

  setup do
    @question = questions(:question8)
    @path = api_question_path(@question.id, format: :json)
    @non_editable_user_login_name = User.where.not(login_name: @question.user.login_name)
                                        .find_by(admin: false).login_name
  end

  test 'get question with REST API' do
    get @path
    assert_response :unauthorized

    [@question.user.login_name, @non_editable_user_login_name].each do |name|
      token = create_token(name, 'testtest')
      get @path, headers: { 'Authorization' => "Bearer #{token}" }

      assert_response :ok
    end
  end

  test 'update question with REST API' do
    patch @path, params: { question: { title: '認証失敗' } }
    assert_response :unauthorized

    [
      @question.user.login_name,
      @non_editable_user_login_name,
      User.find_by(admin: true).login_name
    ].each do |name|
      changed_title = "#{name} changed"
      token = create_token(name, 'testtest')
      patch @path,
            params: { question: { title: changed_title } },
            headers: { 'Authorization' => "Bearer #{token}" }

      if name == @non_editable_user_login_name
        assert_response :bad_request
        next
      end

      assert_response :ok
      assert_equal changed_title, @question.reload.title
    end
  end
end
