require File.join(__dir__, "production")

Rails.application.configure do
  config.action_mailer.default_url_options = { host: ENV["HEROKU_APP_NAME"] + ".herokuapp.com" }
end
