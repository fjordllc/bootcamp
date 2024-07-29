# frozen_string_literal: true

class Admin::FaqsController < AdminController
  before_action :set_faq, only: %i[show edit update destroy]
  before_action :set_category, only: %i[edit new update create]

  def index
    @faqs = FAQ.all
  end

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
    params.require(:faq).permit(:answer, :question, :faqs_category_id)
  end

  def set_faq
    @faq = FAQ.find(params[:id])
  end

  def set_category
    @category = %i[study_content study_environment fee find_job join withdrawal_hibernation_graduation corporate_use]
  end
end
