require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bootcamp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
     config.time_zone = "Tokyo"
     config.i18n.default_locale = :ja

     config.paths.add "lib", eager_load: true

     config.action_view.field_error_proc = Proc.new do |html_tag, instance|
       html_tag.html_safe
     end

     config.active_storage.resolve_model_to_route = :rails_storage_proxy
  end
end
