# frozen_string_literal: true

class Textbooks::SectionsController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def show
    @textbook = Textbook.published.find(params[:textbook_id])
    @chapter = @textbook.chapters.find(params[:chapter_id])
    @section = @chapter.sections.find(params[:id])
  end
end
