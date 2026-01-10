# frozen_string_literal: true

if Rails.env.production?
  MissionControl::Jobs::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(ENV['MISSION_CONTROL_USERNAME'], username) &&
      ActiveSupport::SecurityUtils.secure_compare(ENV['MISSION_CONTROL_PASSWORD'], password)
  end
end
