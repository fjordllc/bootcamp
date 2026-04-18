# frozen_string_literal: true

require 'test_helper'

module LinkFetcher
  class SafetyValidatorTest < ActiveSupport::TestCase
    test '.valid? returns true for a globally accessible URI' do
      globally_accessible_uri = Addressable::URI.parse('https://bootcamp.fjord.jp/').normalize
      assert SafetyValidator.valid?(globally_accessible_uri)
    end

    test '.valid? returns false for a URI that should be blocked' do
      private_network_uri = Addressable::URI.parse('http://10.255.255.255').normalize
      assert_not SafetyValidator.valid?(private_network_uri)
    end

    test '.valid? returns false for a non-HTTP scheme' do
      ftp_uri = Addressable::URI.parse('ftp://example.com/file.txt').normalize
      assert_not SafetyValidator.valid?(ftp_uri)
    end

    test '.valid_http_uri? returns true for a globally accessible URI' do
      globally_accessible_uri = Addressable::URI.parse('https://bootcamp.fjord.jp/').normalize
      assert SafetyValidator.valid_http_uri?(globally_accessible_uri)
    end

    test '.valid_http_uri? returns false for a non-HTTP scheme' do
      ftp_uri = Addressable::URI.parse('ftp://example.com/file.txt').normalize
      assert_not SafetyValidator.valid_http_uri?(ftp_uri)
    end

    test '.valid_http_uri? returns false for a non-default port' do
      non_default_port_uri = Addressable::URI.parse('http://example.com:3000').normalize
      assert_not SafetyValidator.valid_http_uri?(non_default_port_uri)
    end

    test '.safe_ip? returns true for a globally accessible IP' do
      globally_accessible_ip = '8.8.8.8'
      assert SafetyValidator.safe_ip?(IPAddr.new(globally_accessible_ip))
    end

    test '.safe_ip? returns false for an IP that should be blocked' do
      SafetyValidator::BLOCKED_IP_RANGES.each do |ip_range|
        blocked_ip_addr = ip_range.to_range.first
        assert_not SafetyValidator.safe_ip?(blocked_ip_addr)
      end
    end
  end
end
