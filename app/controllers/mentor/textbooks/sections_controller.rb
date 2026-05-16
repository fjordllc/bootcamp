# frozen_string_literal: true

class Mentor::Textbooks::SectionsController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_admin_or_mentor_login
  before_action :require_textbook_enabled
  before_action :set_textbook
  before_action :set_chapter
  before_action :set_section, only: %i[edit update destroy]

  def new
    @section = @chapter.sections.build
  end

  def create
    @section = @chapter.sections.build(section_params)
    if @section.save
      redirect_to mentor_textbook_path(@textbook), notice: '節を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @section.update(section_params)
      redirect_to mentor_textbook_path(@textbook), notice: '節を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @section.destroy!
    redirect_to mentor_textbook_path(@textbook), notice: '節を削除しました。'
  end

  private

  def set_textbook
    @textbook = Textbook.find(params[:textbook_id])
  end

  def set_chapter
    @chapter = @textbook.chapters.find(params[:chapter_id])
  end

  def set_section
    @section = @chapter.sections.find(params[:id])
  end

  def section_params
    params.require(:textbook_section).permit(:title, :body, :estimated_minutes, :position, goals: [], key_terms: [])
  end
end
