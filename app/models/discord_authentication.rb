# frozen_string_literal: true

require 'net/http'

class DiscordAuthentication
  def self.fetch_access_token(code, redirect_uri)
    uri = URI.parse('https://discordapp.com/api/oauth2/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.set_form_data({
                            'client_id' => ENV['DISCORD_CLIENT_ID'],
                            'client_secret' => ENV['DISCORD_CLIENT_SECRET'],
                            'grant_type' => 'authorization_code',
                            'code' => code,
                            'redirect_uri' => redirect_uri
                          })

    response = http.request(request)
    JSON.parse(response.body)['access_token']
  end

  def self.fetch_discord_account_name(access_token)
    uri = URI.parse('https://discordapp.com/api/users/@me')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{access_token}"

    response = http.request(request)
    JSON.parse(response.body)['username']
  end
end
