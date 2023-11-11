# frozen_string_literal: true

class API::Mentor::PracticesController < API::Mentor::BaseController
  def index
    @practices = Practice.order(:id)
  end
end
