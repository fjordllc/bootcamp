# frozen_string_literal: true

class UserGithubAccount
  def initialize(user)
    @user = user
  end

  def clear_github_data
    @user.update(
      github_id: nil,
      github_account: nil,
      github_collaborator: false
    )
  end
end
