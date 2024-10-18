# frozen_string_literal: true

class API::MetadataController < ApplicationController
  def index
    card = LinkCard::Card.new(params)
    render json: card.metadata
  end
end
