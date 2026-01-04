# frozen_string_literal: true

Rails.application.configure do
  config.mission_control.jobs.http_basic_auth_enabled = Rails.env.production?
  config.mission_control.jobs.http_basic_auth_user = ENV.fetch('MISSION_CONTROL_USER', nil)
  config.mission_control.jobs.http_basic_auth_password = ENV.fetch('MISSION_CONTROL_PASSWORD', nil)
end
