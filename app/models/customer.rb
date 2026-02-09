# frozen_string_literal: true

class Customer
  delegate :retrieve, to: :'Stripe::Customer'
end
