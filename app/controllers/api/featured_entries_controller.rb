# frozen_string_literal: true

class API::FeaturedEntriesController < API::BaseController
  PAGER_NUMBER = 25

  def index
    featured_entries = FeaturedEntry.order(created_at: :desc)
    @featured_entries = Kaminari.paginate_array(featured_entries).page(params[:page]).per(PAGER_NUMBER)

    return unless params[:featureable_id] && params[:featureable_type]
  end

  def create
    @featured_entry = FeaturedEntry.create!(featureable: featureable)

    render status: :created, json: @featured_entry
  end

  def destroy
    FeaturedEntry.find(params[:id]).destroy
    head :no_content
  end

  private

  def featureable
    params[:featureable_type].constantize.find_by(id: params[:featureable_id])
  end
end
