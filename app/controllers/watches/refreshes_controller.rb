# frozen_string_literal: true

class Watches::RefreshesController < ApplicationController
  def show
    watchable_class = Watch.watchable_class_for(params[:watchable_type])
    return head :unprocessable_entity unless watchable_class

    @watchable = watchable_class.find(params[:watchable_id])
    @watch = current_user.watches.find_by(watchable: @watchable)
  end
end
