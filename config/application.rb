require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bootcamp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

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
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    config.paths.add "app/presenters", eager_load: true

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end

    config.active_storage.variant_processor = :vips

    # Allow reading legacy Active Storage URLs that were signed with Marshal serializer
    # Rails 7.2 defaults to :json, which cannot read old URLs
    config.active_support.message_serializer = :json_allow_marshal

    # Use SHA1 for key generator to support legacy Active Storage URLs
    # Old URLs were signed with SHA1-based keys
    config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1

    # Disable foreign key validation for fixtures
    # Cloud SQL restricts access to pg_constraint system table
    config.active_record.verify_foreign_keys_for_fixtures = false

    config.view_component.capture_compatibility_patch_enabled = true

    config.to_prepare do
      Doorkeeper::AuthorizationsController.layout "authorization"
    end

    config.transcoder = config_for(:transcoder)
  end
end
