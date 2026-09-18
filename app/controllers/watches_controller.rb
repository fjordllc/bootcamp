# frozen_string_literal: true

class WatchesController < ApplicationController
  def create
    watchable_class = Watch.watchable_class_for(params[:watchable_type])
    return head :unprocessable_entity unless watchable_class

    @watchable = watchable_class.find(params[:watchable_id])
    @watch = current_user.watches.build(watchable: @watchable)

    head :unprocessable_entity unless @watch.save
  end

  def destroy
    watch = current_user.watches.find(params[:id])
    @watchable = watch.watchable
    watch.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { head :no_content }
    end
  end
end
