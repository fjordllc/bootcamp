# frozen_string_literal: true

class TextbooksController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def index
    @textbooks = Textbook.published.order(created_at: :asc)
  end

  def show
    @textbook = Textbook.published.find(params[:id])
  end
end
