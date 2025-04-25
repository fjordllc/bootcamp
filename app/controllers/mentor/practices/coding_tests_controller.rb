class Mentor::Practices::CodingTestsController < ApplicationController
  before_action :require_mentor_login

  def index
    @practice = Practice.find(params[:practice_id])
    @practices_coding_tests = @practice
                          .coding_tests
                          .order(:position)
  end
end
