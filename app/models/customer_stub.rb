# frozen_string_literal: true

module CustomerStub
  WebMock.enable!

  def retrieve(id)
    json = File.read("#{Rails.root}/test/fixtures/files/mock_bodies/customer.json")
    WebMock.stub_request(:get, "https://api.stripe.com/v1/customers/cus_12345678").
      to_return(status: 200, body: json)

    super
  end
end
