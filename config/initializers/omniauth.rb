# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_KEY"], ENV["GITHUB_SECRET"], scope: 'user:email'
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET']

  OmniAuth.config.on_failure = proc { |_env| [302, {'Location' => '/auth/failure', 'Content-Type'=> 'text/html'}, []] }
end
