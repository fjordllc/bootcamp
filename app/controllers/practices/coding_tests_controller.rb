# frozen_string_literal: true

class Practices::CodingTestsController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @practice = Practice.find(params[:practice_id])
    @coding_tests = CodingTest.includes(:practice)
                              .where(practice_id: params[:practice_id])
                              .order(:position)
                              .page(params[:page])
                              .per(PAGER_NUMBER)
  end
end
