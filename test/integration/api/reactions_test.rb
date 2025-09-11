# frozen_string_literal: true

require 'test_helper'

class API::ReactionTest < ActionDispatch::IntegrationTest
  test 'GET /api/reactions returns reactions' do
    report = reports(:report4)
    komagata = users(:komagata)

    token = create_token('komagata', 'testtest')
    post api_reactions_path(reactionable_id: "Report_#{report.id}", kind: 'thumbsup'), as: :json,
                                                                                           headers: { 'Authorization' => "Bearer #{token}" }
    get api_reactions_path(reactionable_id: "Report_#{report.id}"), as: :json,
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
end
