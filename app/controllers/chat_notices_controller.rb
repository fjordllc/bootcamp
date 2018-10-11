# frozen_string_literal: true

class ChatNoticesController < ApplicationController
  def create
    notify(params[:text])
    head :ok
  end
end
