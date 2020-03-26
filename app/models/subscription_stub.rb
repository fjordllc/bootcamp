# frozen_string_literal: true

module SubscriptionStub
  WebMock.allow_net_connect!

  def retrieve(id)
    json = File.read("#{Rails.root}/test/fixtures/files/mock_bodies/subscription.json")
    WebMock.stub_request(:get, "https://api.stripe.com/v1/subscriptions/sub_12345678").
      to_return(status: 200, body: json)

    super
  end
end
