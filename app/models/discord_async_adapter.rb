# frozen_string_literal: true

class DiscordAsyncAdapter
  def initialize(params = {})
    @params = params
  end

  def enqueue(_, params = {})
    params.merge!(@params)
    DiscordJob.perform_later(params)
  end
end
