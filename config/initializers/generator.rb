# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.template_engine :slim
  g.stylesheet_engine :sass
  g.javascripts false
  g.helper false
  g.assets false
end
