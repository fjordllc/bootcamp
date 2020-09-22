# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  def index
    @reports = Report.unchecked.not_wip.list.page(params[:page])
  end
end
