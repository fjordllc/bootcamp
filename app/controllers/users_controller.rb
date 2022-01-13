# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login, except: %i[new create]
  before_action :require_token, only: %i[new] if Rails.env.production?
  before_action :set_user, only: %w[show]
  before_action :set_reports, only: %i[show]
  before_action :set_export, only: %i[show]
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless target_allowlist.include?(@target)
    @watch = params[:watch]

    target_users =
      if @target == 'followings'
        current_user.followees_list(watch: @watch)
      elsif params[:tag]
        User.tagged_with(params[:tag])
      else
        User.users_role(@target)
      end

    @users = target_users
             .page(params[:page]).per(PAGER_NUMBER)
             .preload(:company, :avatar_attachment, :course, :taggings)
             .unretired
             .order(updated_at: :desc)

    @random_tags = User.tags.sample(20)
    @top3_tags_counts = User.tags.limit(3).map(&:count).uniq
    @tag = ActsAsTaggableOn::Tag.find_by(name: params[:tag])
  end

  def show
    @completed_learnings = @user
                           .learnings
                           .includes(:practice)
                           .where(status: 3)
                           .order(updated_at: :desc)
    respond_to do |format|
      format.html
      format.md do
        send_reports_markdown(@reports_for_export)
      end
    end
  end

  def new
    @user = User.new
    case params[:role]
    when 'adviser'
      @user.adviser = true
    when 'trainee'
      @user.trainee = true
    end
    @user.course_id = params[:course_id]
    @user.company_id = params[:company_id]
  end

  def create
    @user = User.new(user_params)
    @user.course_id ||= Course.first.id
    @user.free = true if @user.trainee?

    if @user.staff? || @user.trainee?
      create_free_user!
    else
      create_user!
    end
  end

  private

  def target_allowlist
    target_allowlist = %w[student_and_trainee followings mentor graduate adviser trainee year_end_party]
    target_allowlist.push('job_seeking') if current_user.adviser?
    target_allowlist.concat(%w[job_seeking retired inactive all]) if current_user.mentor? || current_user.admin?
    target_allowlist
  end

  def create_free_user!
    if @user.save
      UserMailer.welcome(@user).deliver_now
      notify_to_chat(@user)
      redirect_to root_url, notice: 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
    else
      render 'new'
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/BlockLength
  def create_user!
    @user.with_lock do
      unless @user.validate
        render 'new'
        return false
      end

      if Card.new.search(email: @user.email)
        logger.error '[Payment] 同じメールアドレスの顧客が既に登録済みです。'
        @user.errors.add :base, '同じメールアドレスの顧客が既に登録済みです。'
        render 'new'
        return false
      end

      token = params[:idempotency_token]

      begin
        customer = Card.new.create(@user, params[:stripeToken], token)
        subscription = Subscription.new.create(customer['id'], "#{token}-subscription")
      rescue Stripe::CardError => e
        logger.error "[Payment] customerの作成時にエラーが発生しました: #{e.message}"
        @user.errors.add :base, I18n.translate("stripe.errors.#{e.code}")
        render 'new'
        return false
      end

      @user.customer_id = customer['id']
      @user.subscription_id = subscription['id']

      if @user.save
        UserMailer.welcome(@user).deliver_now
        notify_to_chat(@user)
        redirect_to root_url, notice: 'サインアップメールをお送りしました。メールからサインアップを完了させてください。'
      else
        render 'new'
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/BlockLength

  def notify_to_chat(user)
    ChatNotifier.message "#{user.name}さんが新たなメンバーとしてJOINしました🎉\r#{url_for(user)}"
  end

  def user_params
    params.require(:user).permit(
      :login_name, :name, :name_kana,
      :email, :course_id, :description,
      :discord_account, :github_account, :twitter_account,
      :facebook_url, :blog_url, :times_url, :password,
      :password_confirmation, :job, :organization,
      :os, :experience, :prefecture_code,
      :company_id, :nda, :avatar,
      :trainee, :adviser, :job_seeker,
      :tag_list, :after_graduation_hope
    )
  end

  def set_user
    @user = User.where(id: params[:id]).or(User.where(login_name: params[:id])).first!
  end

  def require_token
    return unless params[:role]
    return unless !params[:token] || !ENV['TOKEN'] || params[:token] != ENV['TOKEN']

    redirect_to root_path, notice: 'アドバイザー・メンター・研修生登録にはTOKENが必要です。'
  end

  def set_reports
    @reports = @user.reports.list.page(params[:page])
  end

  def set_export
    @reports_for_export = @user.reports.not_wip
  end

  def send_reports_markdown(reports)
    Dir.mktmpdir do |folder_path|
      ReportExporter.export(reports, folder_path)
      send_data(File.read("#{folder_path}/reports.zip"), filename: '日報一覧.zip')
    end
  end
end
