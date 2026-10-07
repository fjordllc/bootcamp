# frozen_string_literal: true

require 'test_helper'

class Connection::GitHubControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:hatsuno)
    @user.update!(github_id: '12345', github_account: 'hatsuno_github', github_collaborator: true)
  end

  test 'the owner can disconnect without clearing profile and collaborator data' do
    sign_in(:hatsuno)
    delete connection_git_hub_path(user_id: @user.id)

    assert_redirected_to user_path(@user)
    assert_nil @user.reload.github_id
    assert_equal 'hatsuno_github', @user.github_account
    assert @user.github_collaborator?
  end

  test 'another non-admin user cannot disconnect the account' do
    sign_in(:kimura)
    delete connection_git_hub_path(user_id: @user.id)

    assert_redirected_to root_path
    assert_equal '12345', @user.reload.github_id
  end
end
