# frozen_string_literal: true

class Practices::ReportsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @include_source = include_source?
    @reports =
      if @include_source
        Report.for_practice_including_source(@practice)
      else
        @practice.reports
      end
    @reports = @reports.list.page(params[:page])
  end

  private

  def include_source?
    # 給付金コースの場合、include_sourceはデフォルトでtrue
    return false unless @practice.grant_course?

    params.fetch(:include_source, 'true') == 'true'
  end
end
