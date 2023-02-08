ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# NOTE: ボイス機能を使用しない設定です。
#       https://github.com/shardlab/discordrb/wiki/Installing-libopus
ENV['DISCORDRB_NONACL'] = 'true'
