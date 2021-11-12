# frozen_string_literal: true

if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.auto_inject = !!ENV['PROFILE']
end
