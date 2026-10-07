# frozen_string_literal: true

class UserGithubConnection
  def initialize(user)
    @user = user
  end

  def connect!(uid:, nickname:)
    @user.update!(github_id: uid, github_account: nickname)
  end

  def disconnect
    @user.update(github_id: nil)
  end

  def clear_data
    @user.update(github_id: nil, github_account: nil, github_collaborator: false)
  end
end
