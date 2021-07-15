# frozen_string_literal: true

class API::NiconicoCalendarsController < API::BaseController
  def show
    @reports = User.find(params[:id])
                   .reports
                   .where(wip: false)
                   .order(reported_on: :asc)
  end
end
