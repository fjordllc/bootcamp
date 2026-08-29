# frozen_string_literal: true

# Userのdelegate宣言からのみ使う、非公開の委譲先オブジェクトをまとめたもの。
# ここに定義されたメソッドは全てprivateであり、Userの公開APIではない。
module UserDelegateTargets
  extend ActiveSupport::Concern

  private

  def follows
    UserFollows.new(self)
  end

  def colleagues_finder
    UserColleagues.new(self)
  end

  def region
    UserRegion.new(self)
  end

  def watcher
    UserWatcher.new(self)
  end

  def event_involvement
    UserEventInvolvement.new(self)
  end

  def regular_event_cleanup
    UserRegularEventCleanup.new(self)
  end
end
