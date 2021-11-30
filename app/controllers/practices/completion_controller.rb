# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  def show
    @practice = Practice.find(params[:practice_id])
    render layout: 'completion'
  end
end
