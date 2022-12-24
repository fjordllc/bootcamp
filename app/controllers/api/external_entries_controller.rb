# frozen_string_literal: true

class API::ExternalEntriesController < API::BaseController
  def index
    @external_entries = ExternalEntry.all.order(published_at: :desc).page(params[:page])
  end
end
