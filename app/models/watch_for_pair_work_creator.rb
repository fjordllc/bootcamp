# frozen_string_literal: true

class WatchForPairWorkCreator
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip? || pair_work.watched?

    watch_pair_work_records = watch_records(pair_work)
    Watch.insert_all(watch_pair_work_records) # rubocop:disable Rails/SkipsModelValidations
  end

  def watch_records(pair_work)
    mentors = User.mentor.to_a
    watching_users = mentors << pair_work.user
    watching_users.uniq.map do |user|
      {
        watchable_type: 'PairWork',
        watchable_id: pair_work.id,
        created_at: Time.current,
        updated_at: Time.current,
        user_id: user.id
      }
    end
  end
end
