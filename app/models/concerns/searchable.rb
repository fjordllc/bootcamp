# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def columns_for_keyword_search(*columns)
      define_singleton_method :ransackable_attributes do |_auth_object = nil|
        columns.map(&:to_s)
      end
    end
  end

  def primary_role
    return user_role if is_a?(User)
    return user_role(user) if respond_to?(:user) && user.present?

    nil
  end

  def user_role(user = self)
    return 'admin' if user.admin?
    return 'mentor' if user.mentor?
    return 'adviser' if user.adviser?
    return 'trainee' if user.trainee?
    return 'graduate' if user.graduated?

    'student' if user.student?
  end
end
