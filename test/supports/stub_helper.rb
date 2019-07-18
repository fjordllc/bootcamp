# frozen_string_literal: true

module StubHelper
  def stub_plan!
    stub_request(:get, "https://api.stripe.com/v1/plans").
      to_return(status: 200, body: { "data": [{ "nickname": "スタンダードプラン" }] }.to_json)
  end

  def stub_create_card!
    stub_request(:post, "https://api.stripe.com/v1/customers").
      with(body: { email: "hatsuno@fjord.jp", source: "tok_visa" }).
      to_return(status: 200, body: { id: "cus_12345678" }.to_json)
  end

  def stub_update_card!
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_12345678").
      to_return(status: 200, body: {}.to_json)

    stub_request(:post, "https://api.stripe.com/v1/customers").
      with(body: { source: "tok_visa" }).
      to_return(status: 200, body: { id: "cus_12345678" }.to_json)
  end

  def stub_subscription_create!
    stub_request(:get, "https://api.stripe.com/v1/plans").
      to_return(status: 200, body: { "data": [{ "id": "plan_12345678", "nickname": "スタンダードプラン" }] }.to_json)

    time = Time.parse("2000-01-04 00:00:00").to_i.to_s

    stub_request(:post, "https://api.stripe.com/v1/subscriptions").
      with(
        body: { customer: "cus_12345678", items: [{ plan: "plan_12345678" }], trial_end: time },
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer sk_test_XLP1Ajz1JvT9jUt5uKGvL0Wd",
          "Connection" => "keep-alive",
          "Content-Type" => "application/x-www-form-urlencoded",
          "Keep-Alive" => "30",
          "Stripe-Version" => "2018-11-08",
          "User-Agent" => "Stripe/v1 RubyBindings/4.5.0",
          "X-Stripe-Client-User-Agent" => '{"bindings_version":"4.5.0","lang":"ruby","lang_version":"2.6.3 p62 (2019-04-16)","platform":"x86_64-linux","engine":"ruby","publisher":"stripe","uname":"Linux version 4.15.0-1035-aws (buildd@lcy01-amd64-005) (gcc version 7.3.0 (Ubuntu 7.3.0-16ubuntu3)) #37-Ubuntu SMP Mon Mar 18 16:15:14 UTC 2019","hostname":"2f014040a926"}'
        }).
      to_return(status: 200, body: { id: "sub_12345678" }.to_json)
  end

  def stub_subscription_destroy!
    stub_request(:post, "https://api.stripe.com/v1/subscriptions/sub_12345678").
      with(body: { cancel_at_period_end: "true" }).
      to_return(status: 200, body: { id: "sub_12345678" }.to_json)
  end

  def stub_subscription_cancel!
    stub_request(:post, "https://api.stripe.com/v1/subscriptions/").
      with(body: { cancel_at_period_end: "true" }).
      to_return(status: 200, body: {}.to_json)
  end
end
