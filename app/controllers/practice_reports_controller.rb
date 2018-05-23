class PracticeReportsController < ApplicationController
  def show
    @practice = Practice.find(params["practice_id"])
  end
end
