# frozen_string_literal: true

require 'test_helper'

class API::ReactionTest < ActionDispatch::IntegrationTest
  setup do
    user = users(:komagata)
    @application = Doorkeeper::Application.create!(
      name: 'Sample Application',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
    @read_token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: user.id,
      scopes: 'read'
    )
    @write_token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: user.id,
      scopes: 'read write'
    )
  end

  test 'POST /api/reactions returns created' do
    report = reports(:report4)

    token = create_token('komagata', 'testtest')
    post api_reactions_path, params: { reactionable_gid: report.to_global_id.to_s, kind: 'smile' },
                             as: :json,
                             headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :created
  end

  test 'POST /api/reactions with unknown reactionable returns not_found' do
    token = create_token('komagata', 'testtest')
    post api_reactions_path, params: { reactionable_gid: 'unknownReactionable' },
                             as: :json,
                             headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :not_found
  end

  test 'POST /api/reactions with read scope returns forbidden' do
    token = Doorkeeper::AccessToken.create!(
      application: @application,
      resource_owner_id: users(:komagata).id,
      scopes: 'read'
    )

    post api_reactions_path,
         params: { reactionable_gid: reports(:report4).to_global_id.to_s, kind: 'smile' },
         as: :json,
         headers: { Authorization: "Bearer #{token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'DELETE /api/reactions/reactionID returns ok' do
    komagata = users(:komagata)
    report   = reports(:report1)
    reaction = Reaction.create!(user_id: komagata.id, reactionable_type: 'Report', reactionable_id: report.id, kind: 'heart')

    token = create_token('komagata', 'testtest')
    delete api_reaction_path(reaction), as: :json,
                                        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :ok
    assert_nil Reaction.find_by(id: reaction.id)
  end

  test 'GET /api/reactions returns reactions' do
    report = reports(:report4)
    komagata = users(:komagata)

    token = create_token('komagata', 'testtest')
    post api_reactions_path, params: { reactionable_gid: report.to_global_id.to_s, kind: 'thumbsup' },
                             as: :json,
                             headers: { 'Authorization' => "Bearer #{token}" }
    get api_reactions_path, params: { reactionable_gid: report.to_global_id.to_s },
                            as: :json,
                            headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :success

    actual = JSON.parse(response.body)

    # avatar_urlについては厳密比較せず、返ってきたurlが意図したformatになっているかのみ検証
    avatar_url = actual.dig('thumbsup', 'users', 0, 'avatar_url')
    assert_match(/komagata\.(webp|jpg)\?.*\z/, avatar_url)

    # 厳密比較からavatar_urlを除外
    actual_without_avatar =
      actual.transform_values do |data|
        {
          'emoji' => data['emoji'],
          'users' => data['users'].map { |user| user.except('avatar_url') }
        }
      end

    komagata = ActiveDecorator::Decorator.instance.decorate(komagata)
    expected = { 'thumbsup' => {
      'emoji' => Reaction.emojis['thumbsup'],
      'users' => [{
        'id' => komagata.id,
        'login_name' => komagata.login_name,
        'user_icon_frame_class' => komagata.user_icon_frame_class
      }]
    } }

    assert_equal expected, actual_without_avatar
  end

  test 'GET /api/reactions with unknown reactionable returns not_found' do
    token = create_token('komagata', 'testtest')
    get api_reactions_path, params: { reactionable_gid: 'unknownReactionable' },
                            as: :json,
                            headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :not_found
  end

  test 'report response includes reactionable_gid' do
    get api_report_path(reports(:report4), format: :json),
        headers: { Authorization: "Bearer #{@read_token.token}" }

    assert_response :ok
    assert_equal reports(:report4).to_global_id.to_s, response.parsed_body['reactionable_gid']
  end

  test 'POST /api/reports/:report_id/reactions returns created' do
    report = reports(:report4)

    assert_difference('Reaction.count') do
      post api_report_reactions_path(report, format: :json),
           params: { kind: 'smile' },
           headers: { Authorization: "Bearer #{@write_token.token}" }
      assert_response :created
    end

    reaction = Reaction.find(response.parsed_body['id'])
    assert_equal report, reaction.reactionable
    assert_equal users(:komagata), reaction.user
    assert_equal 'smile', reaction.kind
  end

  test 'GET /api/reports/:report_id/reactions returns reactions' do
    report = reports(:report4)
    Reaction.create!(reactionable: report, user: users(:komagata), kind: 'thumbsup')

    get api_report_reactions_path(report, format: :json),
        headers: { Authorization: "Bearer #{@read_token.token}" }

    assert_response :ok
    assert_equal Reaction.emojis['thumbsup'], response.parsed_body.dig('thumbsup', 'emoji')
    assert_equal users(:komagata).id, response.parsed_body.dig('thumbsup', 'users', 0, 'id')
  end

  test 'DELETE /api/reports/:report_id/reactions/:id returns ok' do
    report = reports(:report4)
    reaction = Reaction.create!(reactionable: report, user: users(:komagata), kind: 'heart')

    assert_difference('Reaction.count', -1) do
      delete api_report_reaction_path(report, reaction, format: :json),
             headers: { Authorization: "Bearer #{@write_token.token}" }
      assert_response :ok
    end
  end

  test 'POST /api/reports/:report_id/reactions with read scope returns forbidden' do
    post api_report_reactions_path(reports(:report4), format: :json),
         params: { kind: 'smile' },
         headers: { Authorization: "Bearer #{@read_token.token}" }

    assert_response :forbidden
    assert_equal 'invalid_scope', response.parsed_body['error']
  end

  test 'POST /api/reports/:report_id/reactions with unknown report returns not_found' do
    post api_report_reactions_path(0, format: :json),
         params: { kind: 'smile' },
         headers: { Authorization: "Bearer #{@write_token.token}" }

    assert_response :not_found
    assert_equal '日報が見つかりません。', response.parsed_body['message']
  end

  test 'POST /api/reports/:report_id/reactions with invalid kind returns unprocessable_entity' do
    assert_no_difference('Reaction.count') do
      post api_report_reactions_path(reports(:report4), format: :json),
           params: { kind: 'invalid' },
           headers: { Authorization: "Bearer #{@write_token.token}" }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.dig('errors', 'kind').present?
  end

  test 'POST /api/reports/:report_id/reactions with duplicate kind returns unprocessable_entity' do
    report = reports(:report4)
    Reaction.create!(reactionable: report, user: users(:komagata), kind: 'smile')

    assert_no_difference('Reaction.count') do
      post api_report_reactions_path(report, format: :json),
           params: { kind: 'smile' },
           headers: { Authorization: "Bearer #{@write_token.token}" }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body['errors'].present?
  end
end
