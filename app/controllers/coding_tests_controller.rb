# frozen_string_literal: true

class CodingTestsController < ApplicationController
  def show
    @coding_test = CodingTest.find(params[:id])
  end
end
