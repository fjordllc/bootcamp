# frozen_string_literal: true

class TargetUsersQuery
  def initialize(current_user:, target:, watch:, entered_tag:, allowed_targets:)
    @current_user = current_user
    @target = target
    @watch = watch
    @entered_tag = entered_tag
    @allowed_targets = allowed_targets
  end

  def call(search_word: nil)
    target_users = fetch_target_users

    if search_word
      SearchUser.new(
        word: search_word,
        users: target_users,
        target: @target
      ).search
    else
      target_users
    end
  end

  private

  def fetch_target_users
    if @target == 'followings'
      @current_user.followees_list(watch: @watch)
    elsif @entered_tag
      User.active_tagged_with(@entered_tag)
    else
      users = User.users_role(@target, allowed_targets: @allowed_targets)
      @target == 'inactive' ? users.order(:last_activity_at) : users
    end
  end
end
