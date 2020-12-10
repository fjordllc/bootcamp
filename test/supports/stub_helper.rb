# frozen_string_literal: true

module StubHelper
  def stub_plan!
    stub_request(:get, 'https://api.stripe.com/v1/plans')
      .to_return(status: 200, body: { 'data': [{ 'nickname': 'スタンダードプラン' }] }.to_json)
  end

  def stub_create_card!
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .with(body: { email: 'hatsuno@fjord.jp', source: 'tok_visa' })
      .to_return(status: 200, body: { id: 'cus_12345678' }.to_json)
  end

  def stub_update_card!
    stub_request(:get, 'https://api.stripe.com/v1/customers/cus_12345678')
      .to_return(status: 200, body: {}.to_json)

    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .with(body: { source: 'tok_visa' })
      .to_return(status: 200, body: { id: 'cus_12345678' }.to_json)
  end

  def stub_search_card!
    stub_request(:get, 'https://api.stripe.com/v1/customers?email=foo@example.com&limit=1')
      .to_return(status: 200, body: { data: [{ email: 'foo@example.com' }] }.to_json)
  end

  def stub_subscription_create!
    stub_request(:get, 'https://api.stripe.com/v1/plans')
      .to_return(status: 200, body: { 'data': [{ 'id': 'plan_12345678', 'nickname': 'スタンダードプラン' }] }.to_json)

    time = Time.parse('2000-01-04 00:00:00').to_i.to_s

    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .with(body: { customer: 'cus_12345678', items: [{ plan: 'plan_12345678' }], trial_end: time })
      .to_return(status: 200, body: { id: 'sub_12345678' }.to_json)
  end

  def stub_subscription_destroy!
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions/sub_12345678')
      .with(body: { cancel_at_period_end: 'true' })
      .to_return(status: 200, body: { id: 'sub_12345678' }.to_json)
  end

  def stub_subscription_cancel!
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions/')
      .with(body: { cancel_at_period_end: 'true' })
      .to_return(status: 200, body: {}.to_json)
  end

  def stub_subscription_all!
    stub_request(:get, 'https://api.stripe.com/v1/subscriptions?status=all')
      .to_return(status: 200, body: { 'has_more': false, 'data': [{ 'id': 'sub_xxxxxxxx', 'status': 'canceled' }] }.to_json)
  end

  def stub_github!
    names = %w[komagata hatsuno kensyu senpai jobseeker kananashi osnashi]
    names.each do |name|
      stub_request(:get, "https://github.com/#{name}")
        .to_return(status: 200, body: '')
    end
  end
end
