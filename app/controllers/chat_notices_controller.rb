class ChatNoticesController < ApplicationController
  def create
    notify(params[:text])
    head :ok
  end
end
