# frozen_string_literal: true

class PairWorkRematchingNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip?

    notify_pair_work_creator(pair_work)
  end

  private

  def notify_pair_work_creator(pair_work)
    ActivityDelivery.with(pair_work:, receiver: pair_work.user).notify(:rematching_pair_work)
  end
end
