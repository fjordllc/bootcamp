# frozen_string_literal: true

if Rails.env.production?
  MissionControl::Jobs.http_basic_auth_user = ENV['MISSION_CONTROL_USERNAME']
  MissionControl::Jobs.http_basic_auth_password = ENV['MISSION_CONTROL_PASSWORD']
end
