# frozen_string_literal: true

class API::Admin::PracticesController < API::Admin::BaseController
  def index
    @practices = Practice.order(:id)
  end
end
