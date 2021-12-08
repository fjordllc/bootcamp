# frozen_string_literal: true

class API::TalksController < API::BaseController
  def index
    @talks = Talk.all
  end
end
