# frozen_string_literal: true

if Rails.env.development? && ENV.has_key?("RACK_PROFILER")
  require "rack-mini-profiler"
  Rack::MiniProfilerRails.initialize!(Rails.application)
  Rack::MiniProfiler.config.position = "bottom-right"
end
