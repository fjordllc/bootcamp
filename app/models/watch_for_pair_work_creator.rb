# frozen_string_literal: true

class WatchForPairWorkCreator
  def call(payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip? || pair_work.watched?

    watch_pair_work_records = watch_records(pair_work)
    Watch.insert_all(watch_pair_work_records) # rubocop:disable Rails/SkipsModelValidations
  end

  def watch_records(pair_work)
    watch_records_by_mentors(pair_work) << watch_record_by_pair_work_user(pair_work)
  end

  def watch_records_by_mentors(pair_work)
    User.mentor.map do |mentor|
      {
        watchable_type: 'PairWork',
        watchable_id: pair_work.id,
        created_at: Time.current,
        updated_at: Time.current,
        user_id: mentor.id
      }
    end
  end

  def watch_record_by_pair_work_user(pair_work)
    {
      watchable_type: 'PairWork',
      watchable_id: pair_work.id,
      created_at: Time.current,
      updated_at: Time.current,
      user_id: pair_work.user_id
    }
  end
end
