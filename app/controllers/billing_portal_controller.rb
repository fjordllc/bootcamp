# frozen_string_literal: true

class BillingPortalController < ApplicationController
  def create
    session = Stripe::BillingPortal::Session.create(customer: current_user.customer_id)
    redirect_to session.url, allow_other_host: true
  end
end
