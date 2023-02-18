Rails.application.reloader.to_prepare do
  Discord::Server.configure do |config|
    config.guild_id = ENV['DISCORD_GUILD_ID'].presence

    bot_token = ENV['DISCORD_BOT_TOKEN'].presence
    config.authorize_token = "Bot #{bot_token}" if bot_token
  end
  Discord::TimesChannel.config.category_id = ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID'].presence
end
