# frozen_string_literal: true

class Admin::FAQController < AdminController
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

  private

  def faq_params
    params.require(:faq).permit(:answer, :question)
  end
end
