# frozen_string_literal: true

class Mentor::TextbooksController < ApplicationController
  include TextbookFeatureGuard
  before_action :require_admin_or_mentor_login
  before_action :require_textbook_enabled
  before_action :set_textbook, only: %i[edit update destroy]

  def index
    @textbooks = Textbook.order(created_at: :desc)
  end

  def new
    @textbook = Textbook.new
  end

  def create
    @textbook = Textbook.new(textbook_params)
    if @textbook.save
      redirect_to mentor_textbooks_path, notice: '教科書を作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @textbook.update(textbook_params)
      redirect_to mentor_textbooks_path, notice: '教科書を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @textbook.destroy!
    redirect_to mentor_textbooks_path, notice: '教科書を削除しました。'
  end

  private

  def set_textbook
    @textbook = Textbook.includes(chapters: :sections).find(params[:id])
  end

  def textbook_params
    params.require(:textbook).permit(:title, :description, :published, :practice_id)
  end
end
