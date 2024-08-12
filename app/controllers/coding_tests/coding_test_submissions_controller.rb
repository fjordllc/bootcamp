# frozen_string_literal: true

class CodingTests::CodingTestSubmissionsController < ApplicationController
  before_action :set_coding_test

  def index
    @coding_test_submissions = @coding_test.coding_test_submissions.page(params[:page])
  end

  def show
    @coding_test_submission = @coding_test.coding_test_submissions.find(params[:id])
  end

  private

  def set_coding_test
    @coding_test = CodingTest.find(params[:coding_test_id])
  end
end
