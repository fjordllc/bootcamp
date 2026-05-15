# frozen_string_literal: true

class Admin::FaqsController < AdminController
  before_action :set_faq, only: %i[show edit update destroy]
  before_action :set_faq_category, only: %i[index edit new update create]

  def index; end

  def new
    @faq = FAQ.new
  end

  def create
    @faq = FAQ.new(faq_params)

    if @faq.save
      redirect_to admin_faqs_path, notice: 'FAQを作成しました。'
    else
      render 'new'
    end
  end

  def show; end
  def edit; end

  def update
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: 'FAQを更新しました。'
    else
      render 'edit'
    end
  end

  def destroy
    @faq.destroy
    redirect_to admin_faqs_path, notice: 'FAQを削除しました。'
  end

  private

  def faq_params
    params.require(:faq).permit(:answer, :question, :faq_category_id)
  end

  def set_faq
    @faq = FAQ.find(params[:id])
  end

  def set_faq_category
    @faq_categories = FAQCategory.all
  end
end
