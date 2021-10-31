# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock

  c.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method path query body]
  }

  c.before_record do |i|
    i.response.body.force_encoding 'UTF-8'
    if i.response.headers['Content-Type'].include? 'application/json'
      body = JSON.pretty_generate(JSON.parse(i.response.body))
      i.response.body = body if i.response.body.present?
    end
  end

  c.preserve_exact_body_bytes do |http_message|
    name = 'UTF-8' || !http_message.body.valid_encoding?
    http_message.body.encoding.name == name
  end

  driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }
  c.ignore_hosts(*driver_hosts)
end
