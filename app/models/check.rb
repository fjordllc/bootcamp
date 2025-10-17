# frozen_string_literal: true

class Check < ApplicationRecord
  belongs_to :user
  belongs_to :checkable, polymorphic: true
  after_create :clear_cache
  after_destroy :clear_cache
  alias sender user

  validates :user_id, uniqueness: { scope: %i[checkable_id checkable_type] }

  def receiver
    checkable.respond_to?(:user) ? checkable.user : nil
  end

  private

  def clear_cache
    delete_report_cache
    delete_product_cache
  end

  def delete_report_cache
    return unless checkable_type == 'Report'

    report = checkable
    Cache.delete_unchecked_report_count
    Cache.delete_user_unchecked_report_count(report.user_id)
  end

  def delete_product_cache
    return unless checkable_type == 'Product'

    Cache.delete_unchecked_product_count
  end
end
