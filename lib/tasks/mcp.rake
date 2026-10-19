# frozen_string_literal: true

namespace :mcp do
  desc 'Revoke all MCP access tokens and unexchanged grants for a user'
  task revoke_tokens: :environment do
    user = User.find(ENV.fetch('USER_ID'))
    revoked = Mcp::TokenRevoker.call(user:)
    puts "Revoked #{revoked.fetch(:access_tokens)} MCP access token(s) and " \
      "#{revoked.fetch(:authorization_grants)} pending grant(s) for user ID #{user.id}."
  end
end
