# frozen_string_literal: true

require 'test_helper'

module LinkChecker
  class ClientTest < ActiveSupport::TestCase
    test '.request' do
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/example.com', record: :none do
          assert_equal 200, Client.request('http://example.com/')
        end
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/fjord.jp', record: :none do
          assert_equal 404, Client.request('https://lokka.jp/foo')
        end
      end
      stub_request(:get, 'http://foobarbuzzzzzzzzzzzzz.com/').to_raise(SocketError)
      Addrinfo.stub(:getaddrinfo, ->(*) { raise SocketError }) do
        assert_not Client.request('http://foobarbuzzzzzzzzzzzzz.com/')
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/e-words.jp', record: :none do
          assert_equal 200, Client.request('https://e-words.jp/w/単体テスト.html')
        end
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/developer.mozilla.org', record: :none do
          assert_equal 200, Client.request('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials')
        end
      end
    end

    test '#request' do
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/example.com', record: :none do
          assert_equal 200, Client.new('http://example.com/').request
        end
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/fjord.jp', record: :none do
          assert_equal 404, Client.new('https://lokka.jp/foo').request
        end
      end
      stub_request(:get, 'http://foobarbuzzzzzzzzzzzzz.com/').to_raise(SocketError)
      Addrinfo.stub(:getaddrinfo, ->(*) { raise SocketError }) do
        assert_not Client.new('http://foobarbuzzzzzzzzzzzzz.com/').request
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/e-words.jp', record: :none do
          assert_equal 200, Client.new('https://e-words.jp/w/単体テスト.html').request
        end
      end
      with_public_dns do
        VCR.use_cassette 'link_checker/client/request/developer.mozilla.org', record: :none do
          assert_equal 200, Client.new('https://developer.mozilla.org/ja/docs/Web/JavaScript#Tutorials').request
        end
      end
    end

    test '#request fails closed when the TLS certificate cannot be verified' do
      url = 'https://www.tablesgenerator.com/markdown_tables'
      stub_request(:get, url).to_raise(OpenSSL::SSL::SSLError.new('certificate verify failed'))

      with_public_dns { assert_same false, Client.request(url) }
    end

    test '#request rejects private and mixed DNS destinations before transport' do
      {
        'http://127.0.0.1/' => ['127.0.0.1'],
        'http://[::ffff:127.0.0.1]/' => ['::ffff:127.0.0.1'],
        'https://example.com/' => ['93.184.216.34', '10.0.0.1']
      }.each do |url, addresses|
        Addrinfo.stub(:getaddrinfo, addresses.map { |address| Addrinfo.ip(address) }) do
          Net::HTTP.stub(:new, ->(*) { flunk 'unsafe destination reached transport' }) do
            assert_same false, Client.request(url)
          end
        end
      end
    end

    test '#request rejects invalid schemes and userinfo before DNS or transport' do
      ['file:///etc/hosts', 'ftp://example.com/', 'https://user:password@example.com/', 'https://@example.com/', 'http://['].each do |url|
        Addrinfo.stub(:getaddrinfo, ->(*) { flunk 'invalid URL reached DNS' }) do
          OpenURI.stub(:open_uri, ->(*) { flunk 'invalid URL reached OpenURI transport' }) do
            Net::HTTP.stub(:new, ->(*) { flunk 'invalid URL reached transport' }) do
              assert_same false, Client.request(url)
            end
          end
        end
      end
    end

    test '#request rejects unsafe redirects without contacting their destinations' do
      stub_request(:get, 'http://127.0.0.1/private').to_return(status: 200)
      stub_request(:get, 'https://user:password@example.com/private').to_return(status: 200)
      ['http://127.0.0.1/private', 'https://user:password@example.com/private', 'file:///etc/hosts'].each do |destination|
        stub_request(:get, 'https://example.com/').to_return(status: 302, headers: { 'Location' => destination })
        Addrinfo.stub(:getaddrinfo, lambda { |host, *|
          [Addrinfo.ip(host == '127.0.0.1' ? '127.0.0.1' : '93.184.216.34')]
        }) do
          assert_same false, Client.request('https://example.com/')
        end
      end
      assert_not_requested :get, 'http://127.0.0.1/private'
      assert_not_requested :get, 'https://user:password@example.com/private'
    end

    test '#request bounds retrieval and follows relative public redirects' do
      stub_request(:get, 'https://example.com/').to_return(status: 302, headers: { 'Location' => '/page' })
      stub_request(:get, 'https://example.com/page').to_return(status: 404)
      original_get = ExternalContent::HttpClient.method(:get)
      requests = 0
      ExternalContent::HttpClient.stub(:get, lambda { |url, **options|
        requests += 1
        assert_equal 2.megabytes, options[:max_body_bytes]
        assert_equal 10, options[:request_timeout]
        original_get.call(url, **options)
      }) do
        with_public_dns { assert_equal 404, Client.request('https://example.com/') }
      end
      assert_equal 1, requests
    end

    test '#request rejects oversized responses and total timeouts' do
      stub_request(:get, 'https://example.com/').to_return(body: 'x' * (2.megabytes + 1))
      with_public_dns { assert_same false, Client.request('https://example.com/') }

      ExternalContent::HttpClient.stub(:get, ->(*) { raise Timeout::Error }) do
        assert_same false, Client.request('https://example.com/')
      end
    end

    test '#request does not mask programming errors' do
      ExternalContent::HttpClient.stub(:get, ->(*) { raise NoMethodError, 'fictional bug' }) do
        assert_raises(NoMethodError) { Client.request('https://example.com/') }
      end
    end

    test 'checker marks a blocked endpoint as broken without transport' do
      link = LinkChecker::Link.new('private', 'http://127.0.0.1/', 'page', 'https://example.com/page')
      Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('127.0.0.1')]) do
        Net::HTTP.stub(:new, ->(*) { flunk 'unsafe destination reached transport' }) do
          assert_same false, Checker.check_response([link]).first.response
        end
      end
    end

    private

    def with_public_dns(&block)
      Addrinfo.stub(:getaddrinfo, [Addrinfo.ip('93.184.216.34')], &block)
    end
  end
end
