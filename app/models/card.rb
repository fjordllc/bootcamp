# frozen_string_literal: true

class Card
  def self.create(user, card_token)
    Stripe::Customer.create(
      email: user.email,
      source: card_token
    )
  end

  def self.update(customer_id, card_token)
    customer = Stripe::Customer.retrieve(customer_id)
    customer.source = card_token
    customer.save
  end
end
