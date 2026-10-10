# frozen_string_literal: true

require 'test_helper'

class ExternalContent::HttpClientTest < ActiveSupport::TestCase
  test 'pins validated addresses while preserving the hostname and disabling proxies' do
    resolutions = 0
    resolver = lambda do |host, *|
      assert_equal 'example.com', host
      resolutions += 1
      [Addrinfo.ip(resolutions == 1 ? '93.184.216.34' : '127.0.0.1')]
    end
    http = Net::HTTP.new('example.com', 443, nil)
    response = Net::HTTPOK.new('1.1', '200', 'OK')
    response['content-type'] = 'text/plain'
    response.stub(:read_body, ->(&block) { block ? block.call('safe') : 'safe' }) do
      http.stub(:start, lambda { |&block|
        assert_equal '93.184.216.34', http.ipaddr
        assert_equal 'example.com', http.address
        assert_predicate http, :use_ssl?
        assert_not http.proxy?
        block.call(http)
      }) do
        http.stub(:request, lambda { |request, &block|
          assert_equal '/page', request.path
          block.call(response)
        }) do
          Net::HTTP.stub(:new, lambda { |host, port, proxy, *|
            assert_equal ['example.com', 443, nil], [host, port, proxy]
            http
          }) do
            Addrinfo.stub(:getaddrinfo, resolver) do
              assert_equal 'safe', ExternalContent::HttpClient.get('https://example.com/page').body
            end
          end
        end
      end
    end
    assert_equal 1, resolutions
  end

  test 'the actual Net HTTP connection uses the pinned IP instead of resolving the hostname again' do
    resolutions = 0
    resolver = lambda do |*|
      resolutions += 1
      [Addrinfo.ip(resolutions == 1 ? '93.184.216.34' : '127.0.0.1')]
    end
    connection_attempts = []
    # Exercise Net::HTTP#connect, stopping at the socket boundary without network I/O.
    WebMock.stub(:net_http_connect_on_start?, true) do
      TCPSocket.stub(:open, lambda { |address, port, *, **|
        connection_attempts << [address, port]
        raise IOError, 'fictional socket boundary'
      }) do
        Addrinfo.stub(:getaddrinfo, resolver) do
          assert_raises(IOError) { ExternalContent::HttpClient.get('https://example.com/page') }
        end
      end
    end

    assert_equal [['93.184.216.34', 443]], connection_attempts
    assert_equal 1, resolutions
  end

  test 'rejects direct private endpoints including IPv4 mapped IPv6' do
    %w[127.0.0.1 10.0.0.1 169.254.169.254 ::1 ::ffff:127.0.0.1].each do |address|
      Addrinfo.stub(:getaddrinfo, [Addrinfo.ip(address)]) do
        assert_raises(RuntimeError) { ExternalContent::HttpClient.get('https://example.com/private') }
      end
    end
    assert_not_requested :get, /example.com/
  end

  test 'rejects private and credentialed redirect destinations before requesting them' do
    ['http://127.0.0.1/private', 'https://user:password@example.com/private'].each do |destination|
      stub_request(:get, 'https://example.com/redirect').to_return(status: 302, headers: { 'Location' => destination })
      Addrinfo.stub(:getaddrinfo, lambda { |host, *|
        [Addrinfo.ip(host == '127.0.0.1' ? '127.0.0.1' : '93.184.216.34')]
      }) do
        assert_raises(RuntimeError, URI::InvalidURIError) { ExternalContent::HttpClient.get('https://example.com/redirect') }
      end
    end
    assert_not_requested :get, 'http://127.0.0.1/private'
    assert_not_requested :get, 'https://user:password@example.com/private'
  end

  test 'rejects userinfo before DNS or HTTP' do
    Addrinfo.stub(:getaddrinfo, ->(*) { flunk 'must reject credentials before DNS' }) do
      assert_raises(URI::InvalidURIError) { ExternalContent::HttpClient.get('https://user:password@example.com/') }
    end
  end

  test 'stops streaming at size limit before reading later chunks' do
    http = Net::HTTP.new('example.com', 443, nil)
    response = Net::HTTPOK.new('1.1', '200', 'OK')
    chunks_read = 0
    response.stub(:read_body, lambda { |&block|
      %w[1234 5678 unread].each do |chunk|
        chunks_read += 1
        block.call(chunk)
      end
    }) do
      http.stub(:start, ->(&block) { block.call(http) }) do
        http.stub(:request, ->(_request, &block) { block.call(response) }) do
          Net::HTTP.stub(:new, http) do
            Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
              assert_raises(ExternalContent::HttpClient::ResponseTooLarge) do
                ExternalContent::HttpClient.get('https://example.com/large', max_body_bytes: 5)
              end
            end
          end
        end
      end
    end
    assert_equal 2, chunks_read
  end

  test 'applies total timeout around resolution and fetching' do
    Addrinfo.stub(:getaddrinfo, ->(*) { sleep 0.1 }) do
      assert_raises(Timeout::Error) do
        ExternalContent::HttpClient.get('https://example.com/slow', request_timeout: 0.01)
      end
    end
  end
  test 'policy and redirect errors have a narrow type without including supplied URLs' do
    url = 'https://example.com/private?secret=fictional'
    Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('10.0.0.1')]) do
      error = assert_raises(ExternalContent::HttpClient::FetchError) { ExternalContent::HttpClient.get(url) }
      assert_kind_of RuntimeError, error
      assert_not_includes error.message, url
      assert_not_includes error.message, 'secret'
    end
    Addrinfo.stub(:getaddrinfo, []) do
      assert_raises(ExternalContent::HttpClient::FetchError) { ExternalContent::HttpClient.get(url) }
    end
    Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
      stub_request(:get, url).to_return(status: 302)
      assert_raises(ExternalContent::HttpClient::FetchError) { ExternalContent::HttpClient.get(url) }
      stub_request(:get, url).to_return(status: 302, headers: { 'Location' => url })
      assert_raises(ExternalContent::HttpClient::FetchError) { ExternalContent::HttpClient.get(url) }
    end
  end

  test 'HTTPS uses peer verification even for the former link checker exception' do
    socket = Minitest::Mock.new
    socket.expect(:setsockopt, nil, [Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1])
    socket.expect(:close, nil)
    WebMock.stub(:net_http_connect_on_start?, true) do
      TCPSocket.stub(:open, socket) do
        OpenSSL::SSL::SSLSocket.stub(:new, lambda { |_socket, context|
          assert_equal OpenSSL::SSL::VERIFY_PEER, context.verify_mode
          assert context.verify_hostname
          raise OpenSSL::SSL::SSLError, 'certificate verify failed'
        }) do
          Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')]) do
            assert_raises(OpenSSL::SSL::SSLError) do
              ExternalContent::HttpClient.get('https://www.tablesgenerator.com/markdown_tables')
            end
          end
        end
      end
    end
    socket.verify
  end
end
