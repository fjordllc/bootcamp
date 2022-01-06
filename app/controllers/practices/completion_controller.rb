# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  layout 'completion'

  def show
    @practice = Practice.find(params[:practice_id])
  end
end
