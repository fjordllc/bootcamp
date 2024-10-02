# frozen_string_literal: true

module Authentication::LoginHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :admin_login?,
                  :mentor_login?,
                  :admin_or_mentor_login?,
                  :adviser_login?,
                  :staff_login?,
                  :student_login?,
                  :paid_login?,
                  :staff_or_paid_login?,
                  :hibernated_login?,
                  :retired_login?,
                  :hibernated_or_retired_login?
  end

  %i[admin mentor adviser staff student paid hibernated retired].each do |user_type|
    define_method("#{user_type}_login?") do
      logged_in? && current_user.public_send("#{user_type}?")
    end
  end

  def admin_or_mentor_login?
    logged_in? && current_user.admin_or_mentor?
  end

  def hibernated_or_retired_login?
    logged_in? && current_user.hibernated_or_retired?
  end
end
