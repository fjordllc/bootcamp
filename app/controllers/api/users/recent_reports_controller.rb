class API::Users::RecentReportsController < API::BaseController
 
    def index
        # @report = Report.find(params[:id])
        # @reports = @report.user.reports.limit(5).order(reported_on: :DESC)
        @user = User.find(params[:user_id])
        @reports = @user.reports.limit(5).offset(1).order(reported_on: :DESC)
    end

    # private
    # def set_user
    #   @user = User.find(params[:user_id])
    # end
end
