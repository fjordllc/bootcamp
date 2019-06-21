# frozen_string_literal: true

class API::AvailableEmojisController < API::BaseController
  def index
    @available_emojis = Reaction.emojis.map { |key, value| { kind: key, value: value } }
  end
end
