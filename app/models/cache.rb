# frozen_string_literal: true

class Cache
  class << self
    def unchecked_report_count
      Rails.cache.fetch(cache_key('unchecked_report_count')) do
        Report.unchecked.not_wip.count
      end
    end

    def delete_unchecked_report_count
      Rails.cache.delete(cache_key('unchecked_report_count'))
    end

    def user_unchecked_report_count(user)
      Rails.cache.fetch(cache_key('user_unchecked_report_count', user.id)) do
        Report.unchecked.not_wip.user(user).count
      end
    end

    def delete_user_unchecked_report_count(user_id)
      Rails.cache.delete(cache_key('user_unchecked_report_count', user_id))
    end

    def unchecked_product_count
      Rails.cache.fetch(cache_key('unchecked_product_count')) do
        Product.unhibernated_user_products.unchecked.not_wip.count
      end
    end

    def delete_unchecked_product_count
      Rails.cache.delete(cache_key('unchecked_product_count'))
    end

    def unassigned_product_count
      Rails.cache.fetch(cache_key('unassigned_product_count')) do
        Product.unassigned.unchecked.not_wip.count
      end
    end

    def delete_unassigned_product_count
      Rails.cache.delete(cache_key('unassigned_product_count'))
    end

    def self_assigned_no_replied_product_count(user_id)
      Rails.cache.fetch(cache_key('self_assigned_no_replied_product_count', user_id)) do
        Product.unhibernated_user_products.self_assigned_no_replied_products(user_id).unchecked.count
      end
    end

    def delete_self_assigned_no_replied_product_count(user_id)
      Rails.cache.delete(cache_key('self_assigned_no_replied_product_count', user_id))
    end

    def not_solved_question_count
      Rails.cache.fetch(cache_key('not_solved_question_count')) do
        Rails.logger.info '[CACHE MISS] Executing DB query for not_solved_question_count'
        Question.not_solved.not_wip.count
      end
    end

    def delete_not_solved_question_count
      Rails.cache.delete(cache_key('not_solved_question_count'))
    end

    def not_solved_pair_work_count
      Rails.cache.fetch(cache_key('not_solved_pair_work_count')) do
        Rails.logger.info '[CACHE MISS] Executing DB query for not_solved_pair_work_count'
        PairWork.not_solved.not_wip.count
      end
    end

    def delete_not_solved_pair_work_count
      Rails.cache.delete(cache_key('not_solved_pair_work_count'))
    end

    def mentioned_notification_count(user)
      Rails.cache.fetch(cache_key('mentioned_notification_count', user.id)) do
        user.notifications.by_target(:mention).latest_of_each_link.size
      end
    end

    def delete_mentioned_notification_count(user_id)
      Rails.cache.delete(cache_key('mentioned_notification_count', user_id))
    end

    def mentioned_and_unread_notification_count(user)
      Rails.cache.fetch(cache_key('mentioned_and_unread_notification_count', user.id)) do
        user.notifications.by_target(:mention).unreads.latest_of_each_link.size
      end
    end

    def delete_mentioned_and_unread_notification_count(user_id)
      Rails.cache.delete(cache_key('mentioned_and_unread_notification_count', user_id))
    end

    def cache_key(text, user_id = nil)
      [user_id, text].compact.join('-')
    end
  end
end
