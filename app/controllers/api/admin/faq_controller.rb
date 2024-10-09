# frozen_string_literal: true

class API::Admin::FAQController < API::Admin::BaseController
  before_action :set_faq, only: %i[show update]

  def show
    render json: @faq
  end

  def update
    Rails.logger.info "Received params: #{params.inspect}"

    return render_error('FAQ category is required') if missing_faq_category_id?

    return render_error('Invalid insert_at parameter') if invalid_insert_at_param?

    if update_faq_category && update_faq_position
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

  def missing_faq_category_id?
    params[:faq_category_id].blank?.tap do |missing|
      Rails.logger.error 'faq_category_id is missing' if missing
    end
  end

  def invalid_insert_at_param?
    !(params[:insert_at].present? && valid_integer?(params[:insert_at])).tap do |invalid|
      Rails.logger.error "Invalid insert_at parameter: #{params[:insert_at]}" if invalid
    end
  end

  def valid_integer?(str)
    Integer(str)
  rescue StandardError
    false
  end

  def update_faq_category
    @faq.update(faq_category_id: params[:faq_category_id]).tap do |success|
      Rails.logger.error "FAQ update failed during faq_category_id update: #{@faq.errors.full_messages.join(', ')}" unless success
    end
  end

  def update_faq_position
    @faq.insert_at(params[:insert_at].to_i).tap do |success|
      Rails.logger.error "FAQ update failed: #{@faq.errors.full_messages.join(', ')}" unless success
    end
  end

  def render_error(message)
    Rails.logger.error message
    render json: { error: message }, status: :unprocessable_entity
  end
end
