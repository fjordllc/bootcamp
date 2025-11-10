# frozen_string_literal: true

class Api::Mentor::PracticesController < Api::Mentor::BaseController
  def index
    @practices = Practice.order(:id)
  end
end
