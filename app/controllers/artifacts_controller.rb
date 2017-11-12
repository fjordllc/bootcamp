class ArtifactsController < ApplicationController
  before_action :set_practice, only: %i(create)

  def create
    @artifact      = @practice.artifacts.build(artifact_params)
    @artifact.user = current_user
    if @artifact.save
      redirect_to @artifact.practice, notice: t("artifact_create_notice")
    else
      render template: "practices/show"
    end
  end

  private

    def artifact_params
      params.require(:artifact).permit(:content, :done)
    end

    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end
