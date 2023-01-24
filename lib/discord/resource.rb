# frozen_string_literal: true

module Discord
  class Resource
    # NOTE: 2023年1月時点で最新のAPIバージョン
    API_SITE_BASE = 'https://discord.com/api/v10/'
    # NOTE: タイムアウトの初期値が60秒のため利用者の待ち時間を短縮するため変更した
    TIMEOUT_SECONDS = 5

    class << self
      def get(path)
        resource = new(Net::HTTP::Get, site_uri(path))
        resource.request_with_auth
      end

      def delete(path)
        resource = new(Net::HTTP::Delete, site_uri(path))
        resource.request_with_auth
      end

      private

      def site_uri(path)
        URI.join(API_SITE_BASE, path)
      end
    end

    def initialize(method_klass, uri)
      @uri = uri
      @request = method_klass.new(uri.request_uri)
    end

    def request_with_auth
      return nil unless bot_token

      @request.add_field('Authorization', "Bot #{bot_token}")
      http_client.request(@request)
    end

    private

    def bot_token
      ENV['DISCORD_BOT_TOKEN'].presence
    end

    def http_client
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.open_timeout = TIMEOUT_SECONDS
      http.read_timeout = TIMEOUT_SECONDS

      http
    end
  end
end
