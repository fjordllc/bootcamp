# frozen_string_literal: true

class BillingPortalController < ApplicationController
  before_action :require_login

  def create
    session = Stripe::BillingPortal::Session.create(customer: current_user.customer_id)
    redirect_to session.url
  end
end
