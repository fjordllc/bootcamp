# frozen_string_literal: true

class UserHibernation
  def initialize(user)
    @user = user
  end

  def last_hibernation
    return nil if @user.hibernations.empty?

    @user.hibernations.order(:created_at).last
  end

  def hibernation_elapsed_days
    (Time.zone.today - @user.hibernated_at.to_date).to_i
  end

  def scheduled_retire_at
    @user.hibernated_at + User::HIBERNATION_LIMIT if @user.hibernated_at?
  end
end
