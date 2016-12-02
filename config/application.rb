require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "sprockets/es6"

module Interns
  class Application < Rails::Application
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    #gemoji
    config.assets.paths << Emoji.images_path
    config.assets.precompile << "emoji/**/*.png"
  end
end
