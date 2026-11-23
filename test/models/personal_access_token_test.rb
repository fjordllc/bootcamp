# frozen_string_literal: true

require 'test_helper'

class PersonalAccessTokenTest < ActiveSupport::TestCase
  test '.application creates the dedicated application only once' do
    assert_difference -> { Doorkeeper::Application.where(name: PersonalAccessToken::APPLICATION_NAME).count }, 1 do
      assert_equal PersonalAccessToken.application, PersonalAccessToken.application
    end
    assert_equal PersonalAccessToken::APPLICATION_SCOPES, PersonalAccessToken.application.scopes.to_s
  end

  test '.for_user returns active personal access tokens of the user, newest first' do
    mentor = users(:mentormentaro)
    old_token = issue(mentor, created_at: 2.days.ago)
    new_token = issue(mentor, created_at: 1.day.ago)
    issue(mentor).update!(revoked_at: Time.current)
    issue(users(:komagata))
    other_application = Doorkeeper::Application.create!(name: '別のアプリ', redirect_uri: PersonalAccessToken::REDIRECT_URI, scopes: 'read')
    Doorkeeper::AccessToken.create!(application: other_application, resource_owner_id: mentor.id, scopes: 'read')

    assert_equal [new_token, old_token], PersonalAccessToken.for_user(mentor).to_a
  end

  test '.expiration_options returns labels and days' do
    assert_equal [['30日', 30], ['90日', 90], ['365日', 365]], PersonalAccessToken.expiration_options
  end

  test '.available_scopes depends on role' do
    assert_equal %w[read write], PersonalAccessToken.available_scopes(users(:kimura))
    assert_equal %w[read write mentor], PersonalAccessToken.available_scopes(users(:mentormentaro))
    assert_equal %w[read write mentor admin], PersonalAccessToken.available_scopes(users(:komagata))
  end

  test '#scopes= normalizes values' do
    token = PersonalAccessToken.new(scopes: [:write, '', 'write', nil, 'mentor'])
    assert_equal %w[write mentor], token.scopes

    token.scopes = 'write'
    assert_equal %w[write], token.scopes
  end

  test '#save issues a token that always has read scope' do
    token = PersonalAccessToken.new(user: users(:mentormentaro), scopes: %w[write], expires_in_days: 30)

    assert token.save
    assert_equal 'read write', token.access_token.scopes.to_s
    assert_equal 30.days.to_i, token.access_token.expires_in
    assert_equal users(:mentormentaro).id, token.access_token.resource_owner_id
    assert_equal PersonalAccessToken.application, token.access_token.application
  end

  test '#save uses default expiration and read scope when nothing is selected' do
    token = PersonalAccessToken.new(user: users(:mentormentaro))

    assert token.save
    assert_equal 'read', token.access_token.scopes.to_s
    assert_equal PersonalAccessToken::DEFAULT_EXPIRATION_DAYS.days.to_i, token.access_token.expires_in
  end

  test '#save fails without user' do
    assert_not_saved PersonalAccessToken.new(scopes: %w[write])
  end

  test '#save fails with expiration that is not selectable' do
    token = PersonalAccessToken.new(user: users(:mentormentaro), expires_in_days: 31)
    assert_not_saved token
    assert_includes token.errors.full_messages, '有効期限は選択肢の中から選んでください。'
  end

  test '#save fails with scope that the user cannot use' do
    token = PersonalAccessToken.new(user: users(:mentormentaro), scopes: %w[admin])
    assert_not_saved token
    assert_includes token.errors.full_messages, '指定できないスコープが含まれています。'
  end

  private

  def issue(user, created_at: Time.current)
    token = PersonalAccessToken.new(user:)
    token.save
    token.access_token.update!(created_at:)
    token.access_token
  end

  def assert_not_saved(token)
    assert_no_difference -> { Doorkeeper::AccessToken.count } do
      assert_not token.save
    end
    assert_nil token.access_token
  end
end
