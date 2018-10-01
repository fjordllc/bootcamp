class API::Reports::CommentsController < API::BaseController
  def index
    @comments = fetch_report.comments.order(:created_at)
  end

  def create
    @comment = @report.comments.new(comment_params.merge(user: current_user))
    if @comment.save
      render :show, status: :created, location: api_report_comment_url(@report, @comment)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render :show, status: :ok, location: api_report_comment_url(@report, @comment)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private
    def fetch_report
      return @_report if @_report.present?
      @_report = Report.find(params[:report_id])
    end

    def fetch_my_comment
      return @comment if @comment.present?
      @comment = current_user.comments.find(params[:id])
    end

    def comment_params
      params.permit(:body)
    end
end
