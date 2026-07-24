# frozen_string_literal: true

require 'test_helper'

class API::PracticesTest < ActionDispatch::IntegrationTest
  fixtures :practices

  test 'GET /api/practices.json' do
    get api_practices_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_practices_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
  end

  test 'GET /api/practices/1234.json' do
    get api_practice_path(practices(:practice1).id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_practice_path(practices(:practice1).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_practice_path(practices(:practice1).id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'PATCH /api/practices/1234.json' do
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } }
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    patch api_practice_path(practices(:practice1).id, format: :json),
          params: { practice: { memo: 'test' } },
          headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'PATCH /api/practices/1234.json updates Pjord auto check' do
    practice = practices(:practice1)
    practice.update!(pjord_auto_check: false)

    token = create_token('mentormentaro', 'testtest')
    patch api_practice_path(practice.id, format: :json),
          params: { practice: { pjord_auto_check: true } },
          headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    assert_predicate practice.reload, :pjord_auto_check?
  end
end
