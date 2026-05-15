# frozen_string_literal: true

class Card
  def self.all(customer_id)
    Stripe::Customer.list_sources(customer_id)&.data || []
  end

  def self.destroy_all(customer_id)
    all(customer_id).each do |card|
      destroy(customer_id, card['id'])
    end
  end

  def self.destroy(customer_id, card_id)
    Stripe::Customer.delete_source(
      customer_id,
      card_id
    )
  end

  def create(user, card_token, idempotency_key = SecureRandom.uuid)
    Stripe::Customer.create({
                              email: user.email,
                              source: card_token
                            }, {
                              idempotency_key:
                            })
  end

  def update(customer_id, card_token)
    Stripe::Customer.update(customer_id, source: card_token)
  end

  def search(email:)
    result = Stripe::Customer.list(email:, limit: 1)
    return unless result.data.size.positive?

    result.data.first
  end
end
