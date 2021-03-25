# frozen_string_literal: true

require 'test_helper'

class API::QuestionsTest < ActionDispatch::IntegrationTest
  fixtures :questions

  test 'get question with REST API' do
    question = questions(:question1)
    question_get_path = api_question_path(question.id, format: :json)
    get question_get_path
    assert_response :unauthorized

    non_editable_user_login_name = User.where.not(login_name: question.user.login_name)
                                       .find_by(admin: false).login_name
    [question.user.login_name, non_editable_user_login_name].each do |name|
      token = create_token(name, 'testtest')
      get question_get_path,
          headers: { 'Authorization' => "Bearer #{token}" }

      assert_response :ok
    end
  end
end
