# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  def index
    @reports = Report.unchecked.not_wip.list.page(params[:page])
    if @reports.page(params[:page]).count == 0
      render file: "public/404.html", status: 404, layout: false
    end
  end
end
