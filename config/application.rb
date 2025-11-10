require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bootcamp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Rails 7.2対応: secrets メソッドの後方互換性を提供
    def secrets
      @secrets ||= {
        secret_key_base: Rails.application.credentials.secret_key_base || ENV['SECRET_KEY_BASE'],
        stripe: {
          secret_key: ENV['STRIPE_SECRET_KEY'],
          public_key: ENV['STRIPE_PUBLIC_KEY'],
          endpoint_secret: ENV['STRIPE_ENDPOINT_SECRET'],
          tax_rate_id: ENV['STRIPE_TAX_RATE_ID']
        },
        webhook: {
          admin: ENV['WEBHOOK_ADMIN_URL'],
          all: ENV['WEBHOOK_ALL_URL'],
          mentor: ENV['WEBHOOK_MENTOR_URL'],
          introduction: ENV['WEBHOOK_INTRODUCTION_URL']
        },
        open_ai: {
          access_token: ENV['OPENAI_ACCESS_TOKEN']
        }
      }.with_indifferent_access
    end
  end
end
