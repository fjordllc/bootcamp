# frozen_string_literal: true

require 'json'
require 'uri'
require 'stringio'

module Performance
  class CollectorBoundary
    PATH = '/api/performance_reports'

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless collector_path?(env['PATH_INFO'])

      env['action_dispatch.parameter_filter'] = [/.*/m]
      status = validate(env)
      return [status, { 'content-type' => 'application/json', 'cache-control' => 'no-store' }, []] if status

      @app.call(env)
    end

    private

    def collector_path?(path)
      normalized = URI::DEFAULT_PARSER.unescape(path.to_s).gsub(%r{/+}, '/')
      normalized.match?(%r{\A/api/performance_reports(?:\.[^/]+)?/?\z})
    end

    def validate(env)
      return 400 unless env['QUERY_STRING'].to_s.empty?
      return 415 unless env['CONTENT_TYPE'].to_s.split(';').first == 'application/json'

      body = env.fetch('rack.input').read(2049)
      return 413 if body.bytesize > 2048

      parsed = JSON.parse(body)
      return 400 unless Report.new(parsed).valid?

      env['rack.input'] = StringIO.new(body)
      env['CONTENT_LENGTH'] = body.bytesize.to_s
      nil
    rescue JSON::ParserError, EncodingError, IOError
      400
    end
  end
end
