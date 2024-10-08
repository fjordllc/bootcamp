# frozen_string_literal: true

class API::Admin::FAQController < API::Admin::BaseController
  before_action :set_faq, only: %i[show update]

  def show
    render json: @faq
  end

  def update
    # パラメータをログに出力
    Rails.logger.info "Received params: #{params.inspect}"

    if params[:faq_category_id].blank?
      Rails.logger.error 'faq_category_id is missing'
      return render json: { error: 'FAQ category is required' }, status: :unprocessable_entity
    end

    # insert_atパラメータが数値であるか確認
    if params[:insert_at].present? && valid_integer?(params[:insert_at])
      # faq_category_idの更新
      if @faq.update(faq_category_id: params[:faq_category_id])
        # insert_atの処理
        if @faq.insert_at(params[:insert_at].to_i)
          Rails.logger.info "FAQ updated successfully: #{@faq.inspect}"
          head :no_content
        else
          Rails.logger.error "FAQ update failed: #{@faq.errors.full_messages.join(', ')}"
          render json: { errors: @faq.errors.full_messages }, status: :unprocessable_entity
        end
      else
        Rails.logger.error "FAQ update failed during faq_category_id update: #{@faq.errors.full_messages.join(', ')}"
        render json: { errors: @faq.errors.full_messages }, status: :unprocessable_entity
      end
    else
      Rails.logger.error "Invalid insert_at parameter: #{params[:insert_at]}"
      render json: { error: 'Invalid insert_at parameter' }, status: :unprocessable_entity
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
end
