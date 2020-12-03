# frozen_string_literal: true

class API::AvailableEmojisController < API::BaseController
  before_action :set_available_emojis, only: %i(index)

  def index; end
end
