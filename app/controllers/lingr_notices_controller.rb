class LingrNoticesController < ApplicationController
  respond_to :json

  def create
    notify(params[:text])
    head :ok
  end
end
