class Admin::CategoriesController < AdminController
  before_action :set_category, only: %i(show edit update destroy)

  def index
    @categories = Category.order("position")
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_url, notice: t("category_was_successfully_created")
    else
      render action: "new"
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_url, notice: t("category_was_successfully_updated")
    else
      render action: "edit"
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_url, notice: t("category_was_successfully_destroyed")
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(
        :name,
        :slug,
        :description
      )
    end
end
