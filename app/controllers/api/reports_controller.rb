# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def index
    @search_words = params[:word]&.squish&.split(/[[:blank:]]/)&.uniq
    @reports = Report.list.page(params[:page])

    @reports = @reports.joins(:practices).where(practices: { id: params[:practice_id] }) if params[:practice_id].present?

    return if @search_words.blank?

    @reports = @reports.ransack(title_or_description_cont_all: @search_words).result
  end
end
