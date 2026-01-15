# frozen_string_literal: true

if Rails.env.production?
  MissionControl::Jobs.http_basic_auth_user = ENV['MISSION_CONTROL_USERNAME']
  MissionControl::Jobs.http_basic_auth_password = ENV['MISSION_CONTROL_PASSWORD']

  Rails.logger.info "[MissionControl Init] User: #{MissionControl::Jobs.http_basic_auth_user.inspect}"
  Rails.logger.info "[MissionControl Init] Password length: #{MissionControl::Jobs.http_basic_auth_password&.length}"
  Rails.logger.info "[MissionControl Init] Auth enabled: #{MissionControl::Jobs.http_basic_auth_enabled}"
end
