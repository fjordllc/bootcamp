# frozen_string_literal: true

class API::PracticesController < API::BaseController
  include Rails.application.routes.url_helpers
  before_action :require_mentor_login_for_api, only: %i[show update]
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[show], if: -> { doorkeeper_token.present? }
  before_action :require_write_scope, only: %i[update]
  before_action -> { doorkeeper_authorize! :mentor }, only: %i[update], if: -> { doorkeeper_token.present? }
  before_action :set_practice, only: %i[show update]

  def show; end

  def index
    @categories = params[:scoped_by_user] ? current_user.course.categories : Category
    @categories = @categories
                  .eager_load(:practices)
                  .where.not(practices: { id: nil })
                  .order('categories_practices.position')
    @unique_practices = @categories.flat_map(&:practices).uniq
  end

  def update
    @practice.last_updated_user = current_user

    respond_to do |format|
      if @practice.update(practice_params)
        format.turbo_stream
        format.any { head :ok }
      else
        format.turbo_stream { head :unprocessable_entity }
        format.any { head :bad_request }
      end
    end
  end

  private

  def set_practice
    @practice = Practice.find(params[:id])
  end

  def practice_params
    params.require(:practice).permit(:memo, :description, :goal)
  end

  def require_write_scope
    return unless doorkeeper_token.present? || params[:practice]&.slice(:description, :goal).present?

    doorkeeper_authorize! :write
  end
end
