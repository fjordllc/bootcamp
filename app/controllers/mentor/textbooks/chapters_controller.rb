# frozen_string_literal: true

class Mentor::Textbooks::ChaptersController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_admin_or_mentor_login
  before_action :require_textbook_enabled
  before_action :set_textbook
  before_action :set_chapter, only: %i[edit update destroy]

  def new
    @chapter = @textbook.chapters.build
  end

  def create
    @chapter = @textbook.chapters.build(chapter_params)
    if @chapter.save
      redirect_to mentor_textbook_path(@textbook), notice: '章を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @chapter.update(chapter_params)
      redirect_to mentor_textbook_path(@textbook), notice: '章を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter.destroy!
    redirect_to mentor_textbook_path(@textbook), notice: '章を削除しました。'
  end

  private

  def set_textbook
    @textbook = Textbook.find(params[:textbook_id])
  end

  def set_chapter
    @chapter = @textbook.chapters.find(params[:id])
  end

  def chapter_params
    params.require(:textbook_chapter).permit(:title, :position)
  end
end
