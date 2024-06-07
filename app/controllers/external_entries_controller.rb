# frozen_string_literal: true

class ExternalEntriesController < ApplicationController
  def index
    @external_entries = ExternalEntry.with_avatar.order(published_at: :desc).page(params[:page])
  end
end
