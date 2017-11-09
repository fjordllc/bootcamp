class Admin::ArtifactsController < ApplicationController
  before_action :require_admin_login
  before_action :set_artifact, only: %i(show)

  def index
    if params[:done]
      @artifacts = Artifact.completed
    else
      @artifacts = Artifact.confirmation
    end
  end

  def show
  end

  private

    def set_artifact
      @artifact = Artifact.find(params[:id])
    end
end
