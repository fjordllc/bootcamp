# frozen_string_literal: true

class API::Textbooks::ReadingProgressesController < API::BaseController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def create
    @reading_progress = current_user.reading_progresses.find_or_initialize_by(
      textbook_section_id: reading_progress_params[:textbook_section_id]
    )
    @reading_progress.assign_attributes(reading_progress_params)
    if @reading_progress.save
      head(@reading_progress.previously_new_record? ? :created : :ok)
    else
      head :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def update
    @reading_progress = current_user.reading_progresses.find(params[:id])
    if @reading_progress.update(reading_progress_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def reading_progress_params
    params.require(:reading_progress).permit(:textbook_section_id, :read_ratio, :completed, :last_block_index, :last_read_at)
  end
end
