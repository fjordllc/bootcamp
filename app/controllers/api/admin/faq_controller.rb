# frozen_string_literal: true

class API::Admin::FAQController < API::Admin::BaseController
  before_action :set_faq, only: %i[show update]

  def show
    render json: @faq
  end

  def update
    Rails.logger.info "Received params: #{params.inspect}"

    return render_error('FAQ category is required') if params[:faq_category_id].blank?
    return render_error('Invalid insert_at parameter') unless valid_integer?(params[:insert_at])

    if update_faq
      Rails.logger.info "FAQ updated successfully: #{@faq.inspect}"
      head :no_content
    else
      render json: { errors: @faq.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_faq
    @faq = FAQ.find_by(id: params[:id])
    return if @faq

    Rails.logger.error "FAQ not found with ID: #{params[:id]}"
    render json: { error: 'FAQ not found' }, status: :not_found
  end

  def valid_integer?(str)
    Integer(str)
  rescue StandardError
    false
  end

  def update_faq
    FAQ.transaction do
      return false unless @faq.update(faq_category_id: params[:faq_category_id])

      @faq.insert_at(params[:insert_at].to_i)
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "FAQ update failed: #{e.message}"
    false
  end

  def render_error(message)
    Rails.logger.error message
    render json: { error: message }, status: :unprocessable_entity
  end
end
