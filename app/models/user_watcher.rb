# frozen_string_literal: true

class UserWatcher
  def initialize(user)
    @user = user
  end

  def become_watcher!(watchable)
    @user.watches.find_or_create_by!(watchable:)
  end
end
