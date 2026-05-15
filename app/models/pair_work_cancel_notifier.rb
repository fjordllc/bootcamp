# frozen_string_literal: true

class PairWorkCancelNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    notify_watchers(payload[:pair_work], payload[:sender])
  end

  private

  def notify_watchers(pair_work, sender)
    receivers = User.where(id: pair_work.watches.select(:user_id))
    receivers.each do |receiver|
      ActivityDelivery.with(pair_work:, receiver:, sender:).notify(:cancel_pair_work)
    end
  end
end
