# frozen_string_literal: true

class API::SeatsController < API::BaseController
  before_action :require_login

  def index
    @seats = Seat.order(:name)
  end
end
