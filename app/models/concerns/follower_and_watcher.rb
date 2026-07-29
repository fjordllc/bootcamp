# frozen_string_literal: true

module FollowerAndWatcher
  extend ActiveSupport::Concern

  def follow(other_user, watch:)
    active_relationships.create(followed: other_user, watch:)
  end

  def change_watching(other_user, watch)
    following = Following.find_by(follower_id: self, followed_id: other_user)
    following.update(watch:)
  end

  def unfollow(other_user)
    followees.delete(other_user)
  end

  def following?(other_user)
    followees.include?(other_user)
  end

  def watching?(other_user)
    following?(other_user) ? Following.find_by(follower_id: self, followed_id: other_user).watch? : false
  end

  def followees_list(watch: '')
    if %w[true false].include?(watch)
      followees.includes(:passive_relationships).where(followings: { watch: })
    else
      followees
    end
  end

  def become_watcher!(watchable)
    watches.find_or_create_by!(watchable:)
  end
end
