# frozen_string_literal: true

class Watches::RefreshesController < ApplicationController
  def show
    watchable_class = Watch.watchable_class_for(params[:watchable_type])
    return head :unprocessable_entity unless watchable_class

    watchable = watchable_class.find(params[:watchable_id])
    watch = current_user.watches.find_by(watchable:)

    render turbo_stream: turbo_stream.replace(
      ActionView::RecordIdentifier.dom_id(watchable, :watch_toggle),
      partial: 'watches/watch_toggle',
      locals: { watchable:, watch: }
    )
  end
end
