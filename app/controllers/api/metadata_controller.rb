# frozen_string_literal: true

class API::MetadataController < ApplicationController
  def index
    card = LinkCard::Card.new(params)
    metadata = card.metadata

    if metadata
      render json: metadata, status: :ok
    else
      head :bad_request
    end
  end
end
