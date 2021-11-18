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
        Product.unchecked.not_wip.count
      end
    end

    def delete_unchecked_product_count
      Rails.cache.delete 'unchecked_product_count'
    end

    def not_responded_product_count
      Rails.cache.fetch 'not_responded_product_count' do
        Product.not_responded_products.count
      end
    end

    def delete_not_responded_product_count
      Rails.cache.delete 'not_responded_product_count'
    end

    def unassigned_product_count
      Rails.cache.fetch 'unassigned_product_count' do
        Product.unassigned.unchecked.not_wip.count
      end
    end

    def delete_unassigned_product_count
      Rails.cache.delete 'unassigned_product_count'
    end

    def self_assigned_no_replied_product_count(current_user_id)
      Rails.cache.fetch("#{current_user_id}-self_assigned_no_replied_products_count") do
        Product.self_assigned_no_replied_products(current_user_id).unchecked.count
      end
    end

    def delete_self_assigned_no_replied_product_count(current_user_id)
      Rails.cache.delete "#{current_user_id}-self_assigned_no_replied_product_count"
    end

    def not_solved_question_count
      Rails.cache.fetch 'not_solved_question_count' do
        Question.not_solved.count
      end
    end

    def delete_not_solved_question_count
      Rails.cache.delete 'not_solved_question_count'
    end

    def read_announcement_count(current_user_id)
      Rails.cache.fetch "#{current_user_id}-read_announcement_count" do
        Notification.where(user_id: current_user_id).by_target(:announcement).reads.count
      end
    end

    def delete_read_announcement_count(current_user_id)
      Rails.cache.delete "#{current_user_id}-read_announcement_count"
    end

    def unread_announcement_count(current_user_id)
      Rails.cache.fetch "#{current_user_id}-unread_announcement_count" do
        Notification.where(user_id: current_user_id).by_target(:announcement).unreads.count
      end
    end

    def delete_unread_announcement_count(current_user_id)
      Rails.cache.delete "#{current_user_id}-unread_announcement_count"
    end
  end
end
