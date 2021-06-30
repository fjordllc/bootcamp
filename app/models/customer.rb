# frozen_string_literal: true

class Customer
  def retrieve(id)
    Stripe::Customer.retrieve(id)
  end
end
