# frozen_string_literal: true

class Admin::FAQController < AdminController
  before_action :set_faq, only: %i[edit update]
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

  def edit; end

  def update
    if @faq.update(faq_params)
      redirect_to admin_faqs_path, notice: 'FAQを更新しました。'
    else
      render 'edit'
    end
  end

  private

  def faq_params
    params.require(:faq).permit(:answer, :question)
  end

  def set_faq
    @faq = FAQ.find(params[:id])
  end
end
