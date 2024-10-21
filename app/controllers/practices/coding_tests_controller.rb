# frozen_string_literal: true

class Practices::CodingTestsController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @coding_tests = CodingTest.includes(:practice)
                              .where(practice_id: params[:practice_id])
                              .order(:position)
  end
end
