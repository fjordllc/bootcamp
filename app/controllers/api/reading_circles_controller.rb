# frozen_string_literal: true

class Api::ReadingCirclesController < Api::BaseController
  def index
    @reading_circles = RegularEvent.category_reading_circle
                                   .where(wip: false)
                                   .order(updated_at: :desc, id: :desc)
  end
end
