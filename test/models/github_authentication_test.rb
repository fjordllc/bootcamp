# frozen_string_literal: true

require 'test_helper'

class GithubAuthenticationTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  test 'ログインユーザーが存在せず、githubのidが一致しない場合' do
    github_authentication = GithubAuthentication.new(nil, { info: { nickname: 'kimura_github' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_url
    assert_equal result[:alert], 'ログインに失敗しました。先にアカウントを作成後、GitHub連携を行ってください。'
  end

  test 'ログインユーザーが存在せず、githubのidが退会ユーザーの場合' do
    user = users(:yameo)
    user.github_id = 'uid_test_data'
    user.save!

    github_authentication = GithubAuthentication.new(nil, { info: { nickname: 'yameo_github' }, uid: 'uid_test_data' })

    assert_equal github_authentication.authenticate[:path], retirement_path
  end

  test 'ログインユーザーが存在せず、githubのidが通常ユーザーの場合' do
    user = users(:kimura)
    user.github_id = 'uid_test_data'
    user.save!

    github_authentication = GithubAuthentication.new(nil, { info: { name: 'komagata_discord' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_url
    assert_equal result[:notice], 'サインインしました。'
    assert_equal result[:user_id], user.id
  end

  test 'ログインしており、Github連携していないユーザーの場合' do
    user = users(:kimura)
    github_authentication = GithubAuthentication.new(user, { info: { nickname: 'kimura_github' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_path
    assert_equal user.reload.github_account, 'kimura_github'
    assert_equal user.reload.github_id, 'uid_test_data'
  end
end
