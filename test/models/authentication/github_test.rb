# frozen_string_literal: true

require 'test_helper'

class Authentication::GithubTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: 'www.example.com', protocol: 'https' }
  end

  test 'authentication fails when github id does not match' do
    github_authentication = Authentication::Github.new(nil, { info: { nickname: 'kimura_github' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_path
    assert_equal result[:alert], 'ログインに失敗しました。先にアカウントを作成後、GitHub連携を行ってください。'
  end

  test 'retirement path when github id matches a retired user' do
    user = users(:yameo)
    user.github_id = 'uid_test_data'
    user.save!

    github_authentication = Authentication::Github.new(nil, { info: { nickname: 'yameo_github' }, uid: 'uid_test_data' })

    assert_equal github_authentication.authenticate[:path], retirement_path
  end

  test 'authentication succeeds when github id matches a regular user' do
    user = users(:kimura)
    user.github_id = 'uid_test_data'
    user.save!

    github_authentication = Authentication::Github.new(nil, { info: { name: 'komagata_discord' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_path
    assert_equal result[:notice], 'サインインしました。'
    assert_equal result[:user_id], user.id
    assert_equal result[:back], true
  end

  test 'github is linked when user is logged in and not linked with Github' do
    user = users(:kimura)
    github_authentication = Authentication::Github.new(user, { info: { nickname: 'kimura_github' }, uid: 'uid_test_data' })
    result = github_authentication.authenticate

    assert_equal result[:path], root_path
    assert_equal user.reload.github_account, 'kimura_github'
    assert_equal user.reload.github_id, 'uid_test_data'
  end
end
