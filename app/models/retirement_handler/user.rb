# frozen_string_literal: true

class RetirementHandler::User
  def initialize(user)
    @user = user
  end

  def save_user(params)
    @user.assign_attributes(params)
    @user.save(context: :retirement)
  end

  def notification_type
    :retire
  end

  def notify_user
    true
  end

  def notify_admins_and_mentors
    true
  end

  def additional_clean_up
    destroy_card
    @user.clear_github_data
  end

  private

  def destroy_card
    Card.destroy_all(@user.customer_id) if @user.customer_id?
  end
end
