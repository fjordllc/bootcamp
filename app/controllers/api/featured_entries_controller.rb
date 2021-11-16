class API::FeaturedEntriesController < API::BaseController
  def index
    return unless params[:featureable_id] && params[:featureable_type]
    @featured_entries = FeaturedEntry.where(featureable: featureable)
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
