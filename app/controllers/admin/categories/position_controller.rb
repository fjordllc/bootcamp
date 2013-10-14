class Admin::Categories::PositionController < AdminController
  before_action :set_category

  def update
    case params[:move]
    when 'higher'
      @category.move_higher
    when 'lower'
      @category.move_lower
    when 'top'
      @category.move_to_top
    when 'bottom'
      @category.move_to_bottom
    end

    redirect_to admin_categories_url
  end

  private
    def set_category
      @category = Category.find(params[:category_id])
    end
end
