# frozen_string_literal: true

class Textbooks::ChaptersController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def show
    @textbook = Textbook.published.find(params[:textbook_id])
    @chapter = @textbook.chapters.find(params[:id])
    first_section = @chapter.sections.first
    redirect_to textbook_chapter_section_path(@textbook, @chapter, first_section) if first_section
  end
end
