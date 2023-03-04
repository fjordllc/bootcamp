# frozen_string_literal: true

require 'application_system_test_case'

class SignInWithGithubTest < ApplicationSystemTestCase
  fixtures :users

  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:github, { uid: '12345', info: { name: 'komagata', email: 'komagata@fjord.jp' } })
  end

  test 'sign in with GitHub' do
    user = users(:komagata)
    user.update!(github_id: '12345')

    visit '/login'
    click_link 'GitHubアカウントでログイン'
    assert_text 'サインインしました。'
  end

  test 'register GitHub account' do
    visit_with_auth '/current_user/edit', 'komagata'
    click_link 'GitHub アカウントを登録する'
    assert_text 'GitHubと連携しました。'

    visit '/current_user/edit'
    assert_text 'GitHub アカウントは登録されています。'

    click_link 'GitHub アカウントの登録を解除する'
    assert_text 'GitHubとの連携を解除しました。'

    visit '/current_user/edit'
    assert_link 'GitHub アカウントを登録する'
  end
end
