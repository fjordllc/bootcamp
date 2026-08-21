# frozen_string_literal: true

class UserFollows
  def initialize(user)
    @user = user
  end

  def follow(other_user, watch:)
    @user.active_relationships.create(followed: other_user, watch:)
  end

  def unfollow(other_user)
    @user.followees.delete(other_user)
  end

  def following?(other_user)
    @user.followees.include?(other_user)
  end

  def followees_list(watch: '')
    if %w[true false].include?(watch)
      @user.followees.includes(:passive_relationships).where(followings: { watch: })
    else
      @user.followees
    end
  end

  def change_watching(other_user, watch)
    following = Following.find_by(follower_id: @user, followed_id: other_user)
    following.update(watch:)
  end

  def watching?(other_user)
    following?(other_user) ? Following.find_by(follower_id: @user, followed_id: other_user).watch? : false
  end
end
