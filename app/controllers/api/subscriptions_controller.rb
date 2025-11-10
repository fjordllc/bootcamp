# frozen_string_literal: true

class Api::SubscriptionsController < Api::BaseController
  def index
    @subscriptions = Subscription.new.all
  end
end
