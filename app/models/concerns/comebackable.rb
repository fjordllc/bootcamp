# frozen_string_literal: true

module Comebackable
  extend ActiveSupport::Concern

  def last_hibernation
    return nil if hibernations.empty?

    hibernations.order(:created_at).last
  end

  def hibernation_elapsed_days
    (Time.zone.today - hibernated_at.to_date).to_i
  end

  def update_last_returned_at!
    hibernation = last_hibernation
    hibernation.returned_at = Date.current
    hibernation.save!(validate: false)
  end

  def comeback!
    update_last_returned_at!

    if Rails.env.production? && !staging?
      subscription = Subscription.new.create(customer_id, trial: 0)
      self.subscription_id = subscription['id']
    end

    self.hibernated_at = nil
    save!(validate: false)
  end

  def create_comebacked_comment
    User.find_by(login_name: 'pjord').comments.create(
      description: I18n.t('talk.comeback'),
      commentable_id: Talk.find_by(user_id: id).id,
      commentable_type: 'Talk'
    )
  end

  def scheduled_retire_at
    hibernated_at + User::HIBERNATION_LIMIT if hibernated_at?
  end
end
