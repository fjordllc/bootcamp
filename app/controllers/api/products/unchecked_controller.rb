# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)
    @checker_id = params[:checker_id]
    @products = case @target
                when 'unchecked_all'
                  Product.unchecked
                         .not_wip
                         .list
                         .ascending_by_date_of_publishing_and_id
                         .page(params[:page])
                when 'unchecked_no_replied'
                  Product.unchecked_no_replied_products(current_user.id)
                         .unchecked
                         .not_wip
                         .list
                         .page(params[:page])
                end
    @products = @products.where(checker_id: @checker_id) if @checker_id.present?
    @products_grouped_by_elapsed_days = @products.group_by { |product| product.elapsed_days >= 7 ? 7 : product.elapsed_days }
  end

  private

  def target_allowlist
    %w[unchecked_all unchecked_no_replied]
  end
end
