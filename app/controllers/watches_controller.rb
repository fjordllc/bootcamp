# frozen_string_literal: true

class WatchesController < ApplicationController
  def create
    watchable_class = Watch.watchable_class_for(params[:watchable_type])
    return head :unprocessable_entity unless watchable_class

    watchable = watchable_class.find(params[:watchable_id])
    watch = current_user.watches.build(watchable:)

    if watch.save
      render turbo_stream: turbo_stream.replace(
        ActionView::RecordIdentifier.dom_id(watchable, :watch_toggle),
        partial: 'watches/watch_toggle',
        locals: { watchable:, watch: }
      )
    else
      head :unprocessable_entity
    end
  end

  def destroy
    watch = current_user.watches.find(params[:id])
    watchable = watch.watchable
    watch.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(watchable, :watch_toggle),
          partial: 'watches/watch_toggle',
          locals: { watchable:, watch: nil }
        )
      end

      format.html { head :no_content }
    end
  end
end
