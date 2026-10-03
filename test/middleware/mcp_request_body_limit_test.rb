# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class McpRequestBodyLimitTest < ActiveSupport::TestCase
  test 'MCP body cap rejects oversized streaming input without a content length' do
    app_called = false
    app = lambda do |_env|
      app_called = true
      [200, {}, []]
    end
    middleware = Mcp::RequestBodyLimit.new(app)
    body = 'x' * (Rails.configuration.x.mcp.request_max_bytes + 1)

    status, headers, = middleware.call(
      'PATH_INFO' => '/mcp',
      'REQUEST_METHOD' => 'POST',
      'CONTENT_LENGTH' => '',
      'rack.input' => StringIO.new(body)
    )

    assert_equal 413, status
    assert_equal 'no-store', headers.fetch('cache-control')
    assert_not app_called
  end

  test 'DCR request at the body cap is replayed to the application' do
    body = 'x' * 8_192
    app = lambda do |env|
      assert_equal body, env.fetch('rack.input').read
      [201, {}, []]
    end
    middleware = Mcp::RequestBodyLimit.new(app)

    status, = middleware.call(
      'PATH_INFO' => '/oauth/register',
      'REQUEST_METHOD' => 'POST',
      'CONTENT_LENGTH' => body.bytesize.to_s,
      'rack.input' => StringIO.new(body)
    )

    assert_equal 201, status
  end

  test 'oversized bodies are rejected for trailing-slash and duplicate-slash paths' do
    limits = { '/mcp/' => Rails.configuration.x.mcp.request_max_bytes, '//mcp' => Rails.configuration.x.mcp.request_max_bytes, '/oauth/register/' => 8_192 }

    limits.each do |path, limit|
      app_called = false
      app = lambda do |_env|
        app_called = true
        [200, {}, []]
      end
      middleware = Mcp::RequestBodyLimit.new(app)

      status, = middleware.call(
        'PATH_INFO' => path,
        'REQUEST_METHOD' => 'POST',
        'CONTENT_LENGTH' => '',
        'rack.input' => StringIO.new('x' * (limit + 1))
      )

      assert_equal 413, status, path
      assert_not app_called, path
    end
  end

  test 'audit metadata is captured for a trailing-slash MCP path' do
    captured = nil
    app = lambda do |env|
      captured = env['mcp.audit_metadata']
      [200, {}, []]
    end
    middleware = Mcp::RequestBodyLimit.new(app)
    body = { method: 'tools/call', params: { name: 'get_practice' } }.to_json

    middleware.call(
      'PATH_INFO' => '/mcp/',
      'REQUEST_METHOD' => 'POST',
      'CONTENT_LENGTH' => body.bytesize.to_s,
      'rack.input' => StringIO.new(body)
    )

    assert_equal({ method: 'tools/call', tool_name: 'get_practice' }, captured)
  end

  test 'oversized bodies are rejected for non-POST methods without calling the application' do
    %w[PUT DELETE PATCH].each do |method|
      %w[/mcp /oauth/register].each do |path|
        app_called = false
        app = lambda do |_env|
          app_called = true
          [200, {}, []]
        end
        limit = path == '/mcp' ? Rails.configuration.x.mcp.request_max_bytes : 8_192

        status, = Mcp::RequestBodyLimit.new(app).call(
          'PATH_INFO' => path,
          'REQUEST_METHOD' => method,
          'CONTENT_LENGTH' => '',
          'rack.input' => StringIO.new('x' * (limit + 1))
        )

        assert_equal 413, status, "#{method} #{path}"
        assert_not app_called, "#{method} #{path}"
      end
    end
  end

  test 'Content-Length above the cap is rejected for non-POST methods' do
    app = ->(_env) { [200, {}, []] }
    status, = Mcp::RequestBodyLimit.new(app).call(
      'PATH_INFO' => '/mcp',
      'REQUEST_METHOD' => 'PUT',
      'CONTENT_LENGTH' => (Rails.configuration.x.mcp.request_max_bytes + 1).to_s,
      'rack.input' => StringIO.new('')
    )

    assert_equal 413, status
  end

  test 'in-limit GET, PUT and DELETE reach the application with the body replayed' do
    { 'GET' => '', 'PUT' => 'abc', 'DELETE' => '' }.each do |method, body|
      seen = nil
      app = lambda do |env|
        seen = [env['rack.input'].read, env['mcp.audit_metadata']]
        [200, {}, []]
      end

      status, = Mcp::RequestBodyLimit.new(app).call(
        'PATH_INFO' => '/mcp',
        'REQUEST_METHOD' => method,
        'CONTENT_LENGTH' => body.bytesize.to_s,
        'rack.input' => StringIO.new(body)
      )

      assert_equal 200, status, method
      assert_equal [body, nil], seen, method
    end
  end

  test 'a request without rack.input passes through' do
    app = ->(_env) { [200, {}, []] }
    status, = Mcp::RequestBodyLimit.new(app).call('PATH_INFO' => '/mcp', 'REQUEST_METHOD' => 'GET')

    assert_equal 200, status
  end

  test 'audit metadata is captured only for POST' do
    body = { method: 'tools/call', params: { name: 'get_practice' } }.to_json
    captured = {}
    app = lambda do |env|
      captured[env['REQUEST_METHOD']] = env['mcp.audit_metadata']
      [200, {}, []]
    end

    %w[POST PUT].each do |method|
      Mcp::RequestBodyLimit.new(app).call(
        'PATH_INFO' => '/mcp',
        'REQUEST_METHOD' => method,
        'CONTENT_LENGTH' => body.bytesize.to_s,
        'rack.input' => StringIO.new(body)
      )
    end

    assert_equal({ method: 'tools/call', tool_name: 'get_practice' }, captured['POST'])
    assert_nil captured['PUT']
  end
end
