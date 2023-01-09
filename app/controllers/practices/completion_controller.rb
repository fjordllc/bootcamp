# frozen_string_literal: true

class Practices::CompletionController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :refuse_retired_login, raise: false
  skip_before_action :refuse_hibernated_login, raise: false
  layout 'completion'

  def show
    @practice = Practice.find(params[:practice_id])
  end
end
