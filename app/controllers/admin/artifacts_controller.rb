class Admin::ArtifactsController < AdminController

  def index
    @artifacts = Artifact.all
  end

end
