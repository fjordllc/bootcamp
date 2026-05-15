# frozen_string_literal: true

class PairWorkRematchingNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    past_buddy = payload[:past_buddy]
    return if pair_work.wip?

    notify_pair_work_creator_and_past_buddy(pair_work, past_buddy)
  end

  private

  def notify_pair_work_creator_and_past_buddy(pair_work, past_buddy)
    [pair_work.user, past_buddy].compact.each do |receiver|
      ActivityDelivery.with(pair_work:, receiver:).notify(:rematching_pair_work)
    end
  end
end
