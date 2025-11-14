# frozen_string_literal: true

class Admin::FaqCategoriesController < AdminController
  before_action :set_faq_category, only: %i[edit update destroy]

  def index
    @faq_categories = FaqCategory.order(:created_at)
  end

  def new
    @faq_category = FaqCategory.new
  end

  def create
    @faq_category = FaqCategory.new(faq_category_params)

    if @faq_category.save
      redirect_to admin_faq_categories_path, notice: 'FAQカテゴリーを作成しました。'
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if params[:faq_category][:insert_at]
      @faq_category.insert_at(params[:faq_category][:insert_at].to_i)
      return head :ok
    end

    if @faq_category.update(faq_category_params)
      redirect_to admin_faq_categories_path, notice: 'FAQカテゴリーを更新しました。'
    else
      render 'edit'
    end
  end

  def destroy
    @faq_category.destroy
    redirect_to admin_faq_categories_path, notice: 'FAQカテゴリーを削除しました。'
  end

  private

  def faq_category_params
    params.require(:faq_category).permit(:name, :insert_at)
  end

  def set_faq_category
    @faq_category = FaqCategory.find(params[:id])
  end
end
