# frozen_string_literal: true

class Cache
  class << self
    def unchecked_report_count
      Rails.cache.fetch 'unchecked_report_count' do
        Report.unchecked.not_wip.count
      end
    end

    def delete_unchecked_report_count
      Rails.cache.delete 'unchecked_report_count'
    end

    def unchecked_product_count
      Rails.cache.fetch 'unchecked_product_count' do
        Product.unhibernated_user_products.unchecked.not_wip.count
      end
    end

    def delete_unchecked_product_count
      Rails.cache.delete 'unchecked_product_count'
    end

    def unassigned_product_count
      Rails.cache.fetch 'unassigned_product_count' do
        Product.unassigned.unchecked.not_wip.count
      end
    end

    def delete_unassigned_product_count
      Rails.cache.delete 'unassigned_product_count'
    end

    def self_assigned_no_replied_product_count(user_id)
      Rails.cache.fetch("#{user_id}-self_assigned_no_replied_product_count") do
        Product.self_assigned_no_replied_products(user_id).unchecked.count
      end
    end

    def delete_self_assigned_no_replied_product_count(user_id)
      Rails.cache.delete "#{user_id}-self_assigned_no_replied_product_count"
    end

    def not_solved_question_count
      Rails.cache.fetch 'not_solved_question_count' do
        Question.not_solved.count
      end
    end

    def delete_not_solved_question_count
      Rails.cache.delete 'not_solved_question_count'
    end

    def mentioned_notification_count(user)
      Rails.cache.fetch "#{user.id}-mentioned_notification_count" do
        user.notifications.by_target(:mention).latest_of_each_link.size
      end
    end

    def delete_mentioned_notification_count(user_id)
      Rails.cache.delete "#{user_id}-mentioned_notification_count"
    end

    def mentioned_and_unread_notification_count(user)
      Rails.cache.fetch "#{user.id}-mentioned_and_unread_notification_count" do
        user.notifications.by_target(:mention).unreads.latest_of_each_link.size
      end
    end

    def delete_mentioned_and_unread_notification_count(user_id)
      Rails.cache.delete "#{user_id}-mentioned_and_unread_notification_count"
    end
  end
end
