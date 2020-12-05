# frozen_string_literal: true

module SubscriptionStub
  def retrieve(id)
    if Rails.env.development?
      WebMock.allow_net_connect!

      json = File.read(Rails.root.join('test/fixtures/files/mock_bodies/subscription.json'))
      WebMock.stub_request(:get, 'https://api.stripe.com/v1/subscriptions/sub_12345678')
             .to_return(status: 200, body: json)
    end

    super
  end
end
