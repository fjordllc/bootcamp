# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock

  # Ignore Discord webhook requests (handled by AbstractNotifier test mode)
  # Only webhooks are ignored, not the Discord API used by Discord::Server tests
  c.ignore_request do |request|
    uri = URI(request.uri)
    uri.host == 'discord.com' && uri.path.start_with?('/api/webhooks/')
  end

  c.default_cassette_options = {
    record: :once,
    match_requests_on: %i[method path query body],
    allow_playback_repeats: true
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
end

module VCRHelper
  def vcr_options
    {
      record: :once,
      match_requests_on: [
        :method,
        VCR.request_matchers.uri_without_param(:source)
      ],
      allow_playback_repeats: true
    }
  end
end
