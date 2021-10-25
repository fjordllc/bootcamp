# frozen_string_literal: true

class API::SubscriptionsController < API::BaseController
  def index
    @subscriptions = Subscription.new.all
  end
end
