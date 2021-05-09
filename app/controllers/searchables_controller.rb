# frozen_string_literal: true

class SearchablesController < ApplicationController
  before_action :require_login

  def index; end

  private

  def document_type_param
    params[:document_type]&.to_sym || :all
  end
end
