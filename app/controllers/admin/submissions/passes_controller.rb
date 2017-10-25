class Admin::Submissions::PassesController < ApplicationController
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper
  before_action :set_submission, only: %i(show)

  def index
    @submissions = Submission.where(passed: true)
  end

  def show
  end

  private

    def set_submission
      @submission = Submission.find(params[:id])
    end
end
