# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bootcamp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    config.paths.add "lib", eager_load: true

    config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :patch, :delete, :option]
      end
    end

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end
  end
end
