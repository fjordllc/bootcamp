# frozen_string_literal: true

class PairWorkCallbacks
  def after_save(pair_work)
    if pair_work.saved_change_to_attribute?(:published_at, from: nil)
      send_notification_to_mentors(pair_work)
      Rails.logger.info '[CACHE CLEARED#after_save] Cache destroyed for unsolved pair work count.'
      Cache.delete_not_solved_pair_work_count
    elsif pair_work.saved_change_to_attribute?(:reserved_at) || pair_work.saved_change_to_attribute?(:wip)
      Rails.logger.info '[CACHE CLEARED#after_save] Cache destroyed for unsolved pair work count.'
      Cache.delete_not_solved_pair_work_count
    end
  end

  def before_destroy(pair_work)
    return if pair_work.wip? || pair_work.solved?

    Cache.delete_not_solved_pair_work_count
    Rails.logger.info '[CACHE CLEARED#before_destroy] Cache destroyed for unsolved pair work count.'
  end

  def after_destroy(pair_work)
    delete_notification(pair_work)
  end

  private

  def send_notification_to_mentors(pair_work)
    User.mentor.each do |user|
      ActivityDelivery.with(sender: pair_work.user, receiver: user, pair_work:).notify(:came_pair_work) if pair_work.sender != user
    end
  end

  def delete_notification(pair_work)
    Notification.where(link: "/pair_works/#{pair_work.id}").destroy_all
  end
end
