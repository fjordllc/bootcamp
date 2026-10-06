# frozen_string_literal: true

require 'test_helper'

class API::PositionAuthorizationTest < ActionDispatch::IntegrationTest
  ENDPOINTS = [
    %i[categories_practices categories_practice3 category_id api_categories_practice_position_path],
    %i[courses_categories courses_category3 course_id api_courses_category_position_path],
    %i[coding_tests coding_test2 practice_id api_coding_test_position_path],
    %i[survey_question_listings survey_question_listing3 survey_id api_survey_question_listing_position_path]
  ].freeze

  setup do
    coding_tests(:coding_test2).coding_test_cases.create!(input: 'world', output: 'hello world')
  end

  ENDPOINTS.each do |fixture_type, fixture_name, scope_key, path_helper|
    %i[session jwt oauth].each do |authentication|
      %i[kimura advijirou].each do |actor|
        test "#{fixture_type} denies #{actor} with #{authentication} without changing the list" do
          target, list = position_list(fixture_type, fixture_name, scope_key)
          before = list_positions(list)
          headers = authentication_headers(authentication, actor)

          patch public_send(path_helper, target), params: { insert_at: 1 }, as: :json, headers: headers

          assert_equal before, list_positions(list)
          assert_response :forbidden
          assert_equal '権限がありません', response.parsed_body['error']
        end

        test "#{fixture_type} denies #{actor} with #{authentication} before looking up a missing ID" do
          _, list = position_list(fixture_type, fixture_name, scope_key)
          before = list_positions(list)
          headers = authentication_headers(authentication, actor)

          patch public_send(path_helper, 0), params: { insert_at: 1 }, as: :json, headers: headers

          assert_response :forbidden
          assert_equal before, list_positions(list)
        end
      end

      %i[adminonly mentormentaro].each do |actor|
        test "#{fixture_type} allows #{actor} with #{authentication} to reorder the list" do
          target, list = position_list(fixture_type, fixture_name, scope_key)
          before = list_positions(list)
          assert_operator target.position, :>, 1
          expected_ids = [target.id] + before.map(&:first).reject { |id| id == target.id }
          expected = expected_ids.each_with_index.map { |id, index| [id, index + 1] }
          headers = authentication_headers(authentication, actor)

          patch public_send(path_helper, target), params: { insert_at: 1 }, as: :json, headers: headers

          assert_response :no_content
          assert_equal expected, list_positions(list)
        end

        test "#{fixture_type} returns not found for #{actor} with #{authentication} and a missing ID" do
          _, list = position_list(fixture_type, fixture_name, scope_key)
          before = list_positions(list)
          headers = authentication_headers(authentication, actor)

          patch public_send(path_helper, 0), params: { insert_at: 1 }, as: :json, headers: headers

          assert_response :not_found
          assert_equal before, list_positions(list)
        end
      end
    end

    %i[adminonly mentormentaro].each do |actor|
      test "#{fixture_type} denies read-only OAuth for #{actor} without changing the list" do
        target, list = position_list(fixture_type, fixture_name, scope_key)
        before = list_positions(list)
        headers = authentication_headers(:oauth, actor, scopes: 'read')

        patch public_send(path_helper, target), params: { insert_at: 1 }, as: :json, headers: headers

        assert_equal before, list_positions(list)
        assert_response :forbidden
        assert_equal 'invalid_scope', response.parsed_body['error']
      end
    end

    test "#{fixture_type} requires authentication before looking up existing or missing IDs" do
      target, list = position_list(fixture_type, fixture_name, scope_key)
      before = list_positions(list)

      [target.id, 0].each do |id|
        patch public_send(path_helper, id), params: { insert_at: 1 }, as: :json

        assert_response :unauthorized
        assert_equal before, list_positions(list)
      end
    end
  end

  private

  def position_list(fixture_type, fixture_name, scope_key)
    target = public_send(fixture_type, fixture_name)
    [target, target.class.where(scope_key => target.public_send(scope_key))]
  end

  def list_positions(list)
    list.reorder(:position, :id).pluck(:id, :position)
  end

  def authentication_headers(authentication, actor, scopes: 'read write')
    case authentication
    when :session
      sign_in(actor)
      assert_response :redirect
      {}
    when :jwt
      token = create_token(users(actor).login_name, 'testtest')
      assert_response :ok
      assert token.present?
      reset!
      { Authorization: "Bearer #{token}" }
    when :oauth
      application = Doorkeeper::Application.create!(
        name: 'Position authorization test',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
      )
      token = Doorkeeper::AccessToken.create!(application:, resource_owner_id: users(actor).id, scopes:)
      { Authorization: "Bearer #{token.token}" }
    end
  end
end
