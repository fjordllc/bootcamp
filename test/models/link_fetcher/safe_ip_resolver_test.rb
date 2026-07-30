# frozen_string_literal: true

require 'test_helper'

module LinkFetcher
  class SafeIpResolverTest < ActiveSupport::TestCase
    test '.resolve_ips returns IPs when all resolved IPs are safe' do
      globally_accessible_uri = Addressable::URI.parse('https://bootcamp.fjord.jp/').normalize
      safe_ips = ['8.8.8.8', '1.1.1.1']

      Resolv.stub :getaddresses, safe_ips do
        resolve_ips = SafeIpResolver.resolve_ips(globally_accessible_uri)
        assert_equal safe_ips, resolve_ips
      end
    end

    test '.resolve_ips returns nil when any resolved IP is blocked' do
      private_network_uri = Addressable::URI.parse('http://169.254.169.254').normalize
      blocked_ips = ['8.8.8.8', '192.168.1.1']

      Resolv.stub :getaddresses, blocked_ips do
        resolve_ips = SafeIpResolver.resolve_ips(private_network_uri)
        assert_nil resolve_ips
      end
    end

    test '.resolve_ips returns nil for a non-HTTP scheme' do
      ftp_uri = Addressable::URI.parse('ftp://example.com/file.txt').normalize
      assert_nil SafeIpResolver.resolve_ips(ftp_uri)
    end

    test '.valid_http_uri? returns true for a globally accessible URI' do
      globally_accessible_uri = Addressable::URI.parse('https://bootcamp.fjord.jp/').normalize
      assert SafeIpResolver.valid_http_uri?(globally_accessible_uri)
    end

    test '.valid_http_uri? returns false for a non-HTTP scheme' do
      ftp_uri = Addressable::URI.parse('ftp://example.com/file.txt').normalize
      assert_not SafeIpResolver.valid_http_uri?(ftp_uri)
    end

    test '.valid_http_uri? returns false for a non-default port' do
      non_default_port_uri = Addressable::URI.parse('http://example.com:3000').normalize
      assert_not SafeIpResolver.valid_http_uri?(non_default_port_uri)
    end

    test '.all_ips_safe? returns true when all IPs are globally accessible' do
      safe_ips = ['8.8.8.8', '1.1.1.1']
      assert SafeIpResolver.all_ips_safe?(safe_ips)
    end

    test '.all_ips_safe? returns false when any IP is blocked' do
      blocked_ips = ['8.8.8.8', '192.168.1.1']
      assert_not SafeIpResolver.all_ips_safe?(blocked_ips)
    end

    test '.safe_ip? returns true for a globally accessible IP' do
      globally_accessible_ip = '8.8.8.8'
      ip_addr = IPAddr.new(globally_accessible_ip)

      assert SafeIpResolver.safe_ip?(ip_addr)
    end

    test '.safe_ip? returns false for an IP that should be blocked' do
      SafeIpResolver::BLOCKED_IP_RANGES.each do |ip_range|
        blocked_ip_addr = ip_range.to_range.first
        assert_not SafeIpResolver.safe_ip?(blocked_ip_addr)
      end
    end
  end
end
