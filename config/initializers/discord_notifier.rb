# frozen_string_literal: true

Discord::Notifier.setup do |config|
  config.url = ENV['DISCORD_NOTICE_WEBHOOK_URL']
  config.username = 'ピヨルド'
  config.avatar_url = 'https://i.gyazo.com/7099977680d8d8c2d72a3f14ddf14cc6.png'
end
