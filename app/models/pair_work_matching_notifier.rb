# frozen_string_literal: true

class PairWorkMatchingNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip?
    return if !pair_work.saved_change_to_attribute?(:reserved_at, from: nil, to: pair_work.reserved_at)

    notify_watchers(pair_work)
    notify_to_chat(pair_work)
  end

  private

  def notify_watchers(pair_work)
    receiver_ids = pair_work.watches.pluck(:user_id)

    receiver_ids.each do |receiver_id|
      receiver = User.find(receiver_id)
      ActivityDelivery.with(pair_work:, receiver:).notify(:matching_pair_work)
    end
  end

  def notify_to_chat(pair_work)
    ChatNotifier.message(<<~TEXT)
      ペアワーク：「#{pair_work.title}」のマッチングペアが決定しました。
      <#{Rails.application.routes.url_helpers.pair_work_url(pair_work)}>
    TEXT
  end
end
