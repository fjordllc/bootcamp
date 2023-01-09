# frozen_string_literal: true

class API::EventsController < API::BaseController
  before_action :require_login
  before_action :refuse_retired_login
  before_action :refuse_hibernated_login

  def index
    @events = Event.with_avatar
                   .includes(:comments, :users)
                   .order(start_at: :desc)
                   .page(params[:page])
  end
end
