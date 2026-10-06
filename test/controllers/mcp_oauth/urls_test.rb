# frozen_string_literal: true

require 'test_helper'

class McpOauth::UrlsTest < ActiveSupport::TestCase
  Request = Struct.new(:base_url)

  setup do
    @previous_canonical_origin = Rails.configuration.x.mcp.canonical_origin
  end

  teardown do
    Rails.configuration.x.mcp.canonical_origin = @previous_canonical_origin
  end

  test 'canonical_origin uses the configured origin in production instead of the request host' do
    Rails.configuration.x.mcp.canonical_origin = 'https://mcp.example.com'
    urls = urls_with(request_base_url: 'http://attacker.example')

    Rails.stub(:env, ActiveSupport::StringInquirer.new('production')) do
      assert_equal 'https://mcp.example.com', urls.send(:canonical_origin)
      assert_equal 'https://mcp.example.com/mcp', urls.send(:mcp_resource_uri)
    end
  end

  test 'canonical_origin raises ArgumentError in production when no origin is configured' do
    Rails.configuration.x.mcp.canonical_origin = nil
    urls = urls_with(request_base_url: 'http://attacker.example')

    Rails.stub(:env, ActiveSupport::StringInquirer.new('production')) do
      error = assert_raises(ArgumentError) { urls.send(:canonical_origin) }
      assert_equal 'MCP canonical origin is not configured', error.message
    end
  end

  test 'canonical_origin falls back to the request base URL outside production' do
    Rails.configuration.x.mcp.canonical_origin = nil
    urls = urls_with(request_base_url: 'http://www.example.com')

    assert_equal 'http://www.example.com', urls.send(:canonical_origin)
  end

  private

  def urls_with(request_base_url:)
    request = Request.new(request_base_url)
    Class.new do
      include McpOauth::Urls

      define_method(:request) { request }
    end.new
  end
end
