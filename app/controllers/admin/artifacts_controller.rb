class Admin::ArtifactsController < AdminController
  before_action :set_artifact, only: %i(show)
  before_action :set_artifact, only: %i(show update)
  include Rails.application.routes.url_helpers
  include Gravatarify::Helper

  def index
    if params[:done]
      @artifacts = Artifact.completed
    else
      @artifacts = Artifact.confirmation
    end
  end

  def show
  end

  def update
    if @artifact.practice.complete(@artifact.user)
      @artifact.to_done
      notify_to_slack(@artifact)

      redirect_to admin_artifacts_path, notice: t("artifact_done_message")
    else
      render :show
    end
  end

  private

    def set_artifact
      @artifact = Artifact.find(params[:id])
    end

    def notify_to_slack(artifact)
      name = "#{artifact.user.login_name}"
      link = "<#{practice_url(artifact.practice)}#practice_#{artifact.practice.id}|#{artifact.practice.title}>"

      notify "#{name} さん #{artifact.practice.title}の課題確認しました。 #{link}",
        username:    "#{current_user.login_name} (#{current_user.full_name})",
        icon_url:    gravatar_url(current_user),
        attachments: [{
          fallback: "passed body.",
          text:     "#{artifact.practice.title}のプラクティス完了です！"
        }]
    end
end
