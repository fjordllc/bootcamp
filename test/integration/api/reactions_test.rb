# frozen_string_literal: true

require 'test_helper'

class API::ReactionTest < ActionDispatch::IntegrationTest
  test 'POST /api/reactions returns created' do
    report = reports(:report4)

    token = create_token('komagata', 'testtest')
    post api_reactions_path(reactionable_gid: report.to_global_id.to_s, kind: 'smile'), as: :json,
                                                                                        headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :created
  end

  test 'POST /api/reactions with unknown reactionable returns not_found' do
    token = create_token('komagata', 'testtest')
    post api_reactions_path(reactionable_gid: 'unknownReactionable'), as: :json,
                                                                      headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :not_found
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
    post api_reactions_path(reactionable_gid: report.to_global_id.to_s, kind: 'thumbsup'), as: :json,
                                                                                           headers: { 'Authorization' => "Bearer #{token}" }
    get api_reactions_path(reactionable_gid: report.to_global_id.to_s), as: :json,
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
    get api_reactions_path(reactionable_gid: 'unknownReactionable'), as: :json,
                                                                     headers: { 'Authorization' => "Bearer #{token}" }

    assert_response :not_found
  end
end
