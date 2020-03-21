# frozen_string_literal: true

class Customer
  prepend CustomerStub if Rails.env.development?

  def retrieve(id)
    Stripe::Customer.retrieve(id)
  end
end
