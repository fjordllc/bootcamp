# frozen_string_literal: true

if Rails.env.production?
  # 一時的にハードコードでテスト
  MissionControl::Jobs.http_basic_auth_user = 'fjord'
  MissionControl::Jobs.http_basic_auth_password = 'testtest'

  Rails.logger.info "[MissionControl Init] User: #{MissionControl::Jobs.http_basic_auth_user.inspect}"
  Rails.logger.info "[MissionControl Init] Password length: #{MissionControl::Jobs.http_basic_auth_password&.length}"
  Rails.logger.info "[MissionControl Init] Auth enabled: #{MissionControl::Jobs.http_basic_auth_enabled}"
end
