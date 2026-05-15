# NOTE: ボイス機能を使用しない設定です。
#       https://github.com/shardlab/discordrb/wiki/Installing-libopus
ENV['DISCORDRB_NONACL'] = 'true'
require 'discordrb'

Rails.application.reloader.to_prepare do
  Discord::Server.guild_id = ENV['DISCORD_GUILD_ID'].presence

  bot_token = ENV['DISCORD_BOT_TOKEN'].presence
  Discord::Server.authorize_token = "Bot #{bot_token}" if bot_token

  Discord::TimesCategory.default_times_category_id = ENV['DISCORD_TIMES_CHANNEL_CATEGORY_ID'].presence
end
