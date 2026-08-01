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
end
