# frozen_string_literal: true

if Rails.env.production?
  staging = ENV['DB_NAME'] == 'bootcamp_staging'

  if staging
    # ステージング環境ではアプリ全体にBasic認証がかかっているため、
    # MissionControlの認証を無効にして二重認証を防ぐ
    MissionControl::Jobs.http_basic_auth_enabled = false
  else
    # 本番環境ではMissionControlの認証を有効にする
    MissionControl::Jobs.http_basic_auth_user = ENV['MISSION_CONTROL_USERNAME']
    MissionControl::Jobs.http_basic_auth_password = ENV['MISSION_CONTROL_PASSWORD']
  end
end
