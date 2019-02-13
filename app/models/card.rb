# frozen_string_literal: true

class Card
  def self.create(user, card_token)
    customer = Stripe::Customer.create(
      email: user.email,
      source: card_token
    )
    user.update(customer_id: customer["id"])
  end

  def self.update(customer_id, card_token)
    customer = Stripe::Customer.retrieve(customer_id)
    customer.source = card_token
    customer.save
  end
end
