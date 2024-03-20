# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_KEY"], ENV["GITHUB_SECRET"], scope: 'user:email'
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET']

  OmniAuth.config.on_failure = proc do |env|
    error_type = env['omniauth.error.type']
    new_path = "/auth/failure?message=#{error_type}"
    [302, {'Location' => new_path, 'Content-Type'=> 'text/html'}, []]
  end
end
