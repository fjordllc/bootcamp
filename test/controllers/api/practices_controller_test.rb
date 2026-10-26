# frozen_string_literal: true

require 'test_helper'

class API::PracticesControllerTest < ActionDispatch::IntegrationTest
  fixtures :practices

  setup do
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end

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

  test 'PATCH /api/practices/1234.json updates content' do
    practice = practices(:practice1)
    mentor = users(:mentormentaro)
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: mentor.id,
      scopes: 'read write mentor'
    )

    patch api_practice_path(practice, format: :json),
          params: { practice: { description: 'APIから更新した内容', goal: 'APIから更新した目的' } },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :ok
    assert_equal 'APIから更新した内容', practice.reload.description
    assert_equal 'APIから更新した目的', practice.goal
    assert_equal mentor, practice.last_updated_user
  end

  test 'PATCH /api/practices/1234.turbo_stream replaces the practice memo' do
    practice = practices(:practice1)
    memo = 'Turbo Streamで更新したメモ'
    token = create_token('mentormentaro', 'testtest')

    patch api_practice_path(practice),
          params: { practice: { memo: } },
          headers: {
            Authorization: "Bearer #{token}",
            Accept: 'text/vnd.turbo-stream.html'
          }

    assert_response :ok
    assert_select "turbo-stream[action='replace'][target='practice_#{practice.id}']"
    assert_equal memo, practice.reload.memo
  end

  test 'PATCH /api/practices/1234.turbo_stream returns unprocessable entity when invalid' do
    practice = practices(:practice1)
    original_description = practice.description
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read write mentor'
    )

    patch api_practice_path(practice),
          params: { practice: { description: '' } },
          headers: {
            Authorization: "Bearer #{token.token}",
            Accept: 'text/vnd.turbo-stream.html'
          }

    assert_response :unprocessable_entity
    assert_equal original_description, practice.reload.description
  end

  test 'PATCH /api/practices/1234.json requires write scope to update content' do
    practice = practices(:practice1)
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:mentormentaro).id,
      scopes: 'read mentor'
    )

    patch api_practice_path(practice, format: :json),
          params: { practice: { description: '更新されない内容' } },
          headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_not_equal '更新されない内容', practice.reload.description
  end

  test 'PATCH /api/practices/1234.json requires OAuth token to update content' do
    practice = practices(:practice1)
    token = create_token('mentormentaro', 'testtest')

    patch api_practice_path(practice, format: :json),
          params: { practice: { description: '更新されない内容' } },
          headers: { Authorization: "Bearer #{token}" }

    assert_response :unauthorized
    assert_not_equal '更新されない内容', practice.reload.description
  end
end
