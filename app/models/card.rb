# frozen_string_literal: true

class Card
  def create(user, card_token, idempotency_key = SecureRandom.uuid)
    Stripe::Customer.create({
                              email: user.email,
                              source: card_token
                            }, {
                              idempotency_key: idempotency_key
                            })
  end

  def update(customer_id, card_token)
    customer = Stripe::Customer.retrieve(customer_id)
    customer.source = card_token
    customer.save
  end

  def search(email:)
    result = Stripe::Customer.list(email: email, limit: 1)
    return unless result.data.size > 0

    result.data.first
  end
end
