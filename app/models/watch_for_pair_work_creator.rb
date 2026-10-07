# frozen_string_literal: true

class WatchForPairWorkCreator
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip?
    return unless pair_work.saved_change_to_attribute?(:published_at, from: nil)

    watching_users = (User.mentor.to_a << pair_work.user).uniq
    Watch.register_all(watchable: pair_work, users: watching_users)
  end
end
