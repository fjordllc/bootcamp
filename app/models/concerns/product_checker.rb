# frozen_string_literal: true

module ProductChecker
  extend ActiveSupport::Concern

  def save_checker(user_id)
    return false if other_checker_exists?(user_id)

    self.checker_id = user_id
    Cache.delete_self_assigned_no_replied_product_count(user_id)
    save!
  end

  def other_checker_exists?(user_id)
    checker_id.present? && checker_id != user_id
  end

  def unassigned?
    checker_id.nil?
  end

  def checker_name
    checker&.login_name
  end

  def checker_avatar
    checker&.avatar_url
  end

  def change_learning_status(status)
    learning = Learning.find_or_initialize_by(
      user_id: user.id,
      practice_id: practice.id
    )
    learning.update!(status:)
  end

  def last_commented_user
    Rails.cache.fetch "/model/product/#{id}/last_commented_user" do
      commented_users.last
    end
  end
end
