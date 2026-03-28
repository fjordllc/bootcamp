# frozen_string_literal: true

class API::Textbooks::TermExplanationsController < API::BaseController
  include TextbookFeatureGuard
  before_action :require_textbook_enabled

  def show
    @term_explanation = TermExplanation.find(params[:id])
  end
end
