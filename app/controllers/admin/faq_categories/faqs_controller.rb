# frozen_string_literal: true

class Admin::FAQCategories::FaqsController < AdminController
  before_action :set_faq_category, only: %i[index update]

  def index
    @faqs = @faq_category.faqs
  end

  def update
    faq = @faq_category.faqs.find(params[:id])
    faq.insert_at(params[:faq][:insert_at].to_i)
    head :ok
  end

  private

  def set_faq_category
    @faq_category = FAQCategory.find(params[:faq_category_id])
  end
end
