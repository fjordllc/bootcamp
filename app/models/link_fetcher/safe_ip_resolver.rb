# frozen_string_literal: true

module LinkFetcher
  module SafeIpResolver
    BLOCKED_IP_RANGES = [
      # ループバック（SSRFで内部サービスに到達可能なためブロック）
      IPAddr.new('127.0.0.0/8'),
      IPAddr.new('::1/128'),

      # プライベートネットワーク（SSRFで社内/VPCリソースに到達可能なためブロック）
      IPAddr.new('10.0.0.0/8'),
      IPAddr.new('172.16.0.0/12'),
      IPAddr.new('192.168.0.0/16'),

      # リンクローカル（メタデータAPI等に到達可能なためブロック）
      IPAddr.new('169.254.0.0/16'),
      IPAddr.new('fe80::/10'),

      # IPv6 ユニークローカルアドレス（内部ネットワークへのアクセスを防ぐためブロック）
      IPAddr.new('fc00::/7'),

      # 旧site-local（廃止済みだが内部ネットワーク扱いのため念の為ブロック）
      IPAddr.new('fec0::/10'),

      # 無効・未指定アドレス（接続先として無効、且つ挙動が不安定のためブロック）
      IPAddr.new('0.0.0.0/32'),
      IPAddr.new('::/128'),

      # CGNAT（外部から到達すべきでない領域のためブロック）
      IPAddr.new('100.64.0.0/10'),

      # IPv4-mapped IPv6（IPv4アドレスをIPv6で表現してのフィルタ回避を防ぐためブロック）
      IPAddr.new('::ffff:0:0/96')
    ].freeze

    class InvalidUriError < StandardError; end
    class UnsafeIpError < StandardError; end

    module_function

    def resolve_ips(uri)
      raise InvalidUriError unless valid_http_uri?(uri)

      ips = Resolv.getaddresses(uri.host)
      raise UnsafeIpError unless all_ips_safe?(ips)

      ips
    rescue InvalidUriError => e
      Rails.logger.info("[SafeResolver] #{e.class}: scheme=#{uri.scheme} host=#{uri.host}")
      nil
    rescue UnsafeIpError => e
      Rails.logger.warn("[SafeResolver] #{e.class}: unsafe ip detected host=#{uri.host}")
      nil
    end

    def valid_http_uri?(uri)
      port = uri.port || uri.inferred_port

      port.in?([80, 443]) && uri.scheme.downcase.in?(%w[http https])
    end

    def all_ips_safe?(ips)
      ip_addrs = ips.map { |ip| IPAddr.new(ip) }
      ip_addrs.all? { |ip| safe_ip?(ip) }
    end

    def safe_ip?(ip_addr)
      BLOCKED_IP_RANGES.none? { |ip_range| ip_range.include?(ip_addr) }
    end
  end
end
