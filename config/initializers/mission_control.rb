# frozen_string_literal: true

if Rails.env.production?
  MissionControl::Jobs::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
    expected_username = ENV['MISSION_CONTROL_USERNAME'].to_s
    expected_password = ENV['MISSION_CONTROL_PASSWORD'].to_s

    Rails.logger.info "[MissionControl Auth] Expected username length: #{expected_username.length}, Got: #{username.to_s.length}"
    Rails.logger.info "[MissionControl Auth] Expected password length: #{expected_password.length}, Got: #{password.to_s.length}"

    result = ActiveSupport::SecurityUtils.secure_compare(expected_username, username.to_s) &&
             ActiveSupport::SecurityUtils.secure_compare(expected_password, password.to_s)

    Rails.logger.info "[MissionControl Auth] Result: #{result}"
    result
  end
end
