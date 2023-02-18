Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY'].presence
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY'].presence
  config.handle_timeouts_gracefully = false
end
