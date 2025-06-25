# frozen_string_literal: true

class PairWorkNotifier
  def call(_name, _started, _finished, _unique_id, payload)
    pair_work = payload[:pair_work]
    return if pair_work.wip?
    return unless pair_work.saved_change_to_attribute?(:published_at, from: nil)

    notify_mentors(pair_work)
    notify_to_chat(pair_work)
  end

  private

  def notify_mentors(pair_work)
    User.mentor.each do |user|
      ActivityDelivery.with(receiver: user, pair_work:).notify(:came_pair_work) if pair_work.user != user
    end
  end

  def notify_to_chat(pair_work)
    ChatNotifier.message(<<~TEXT)
      ペアワーク：「#{pair_work.title}」を#{pair_work.user.login_name}さんが作成しました。
      <#{Rails.application.routes.url_helpers.pair_work_url(pair_work)}>
    TEXT
  end
end
