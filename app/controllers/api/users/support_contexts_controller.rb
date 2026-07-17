# frozen_string_literal: true

class API::Users::SupportContextsController < API::BaseController # rubocop:todo Metrics/ClassLength
  SUPPORT_CONTEXT_LIMIT = 5

  before_action :require_admin_or_mentor
  before_action :set_user

  def show
    render json: {
      user: support_user_json,
      current_practices: @user.active_practices.map { |practice| practice_json(practice) },
      recent_reports: recent_reports.map { |report| report_json(report) },
      recent_products: recent_products.map { |product| product_json(product) },
      recent_questions: recent_questions.map { |question| question_json(question) },
      talk: talk_json,
      recent_mentor_memos: recent_mentor_memos.map { |mentor_memo| mentor_memo_json(mentor_memo) },
      learning_progress: learning_progress_json
    }
  end

  private

  def require_admin_or_mentor
    render json: { message: '権限がありません。' }, status: :forbidden unless current_user.admin_or_mentor?
  end

  def set_user
    @user = User.find_by(id: params[:user_id])
    render json: { message: 'ユーザーが見つかりません。' }, status: :not_found unless @user
  end

  def support_user_json
    {
      id: @user.id,
      login_name: @user.login_name,
      name: @user.name,
      long_name: "#{@user.login_name} (#{@user.name_kana})",
      roles: user_roles,
      primary_role: user_roles.first,
      company: company_json,
      course: course_json
    }
  end

  def company_json
    return unless @user.company

    { id: @user.company.id, name: @user.company.name }
  end

  def user_roles
    roles = %i[retired training_completed hibernationed admin mentor adviser graduate trainee].filter do |role|
      role_value(role)
    end
    roles.presence || [:student]
  end

  def role_value(role)
    case role
    when :hibernationed
      @user.hibernated?
    when :graduate
      @user.graduated?
    else
      @user.public_send("#{role}?")
    end
  end

  def course_json
    return unless @user.course

    { id: @user.course.id, title: @user.course.title }
  end

  def recent_reports
    @recent_reports ||= @user.reports.not_wip.order(reported_on: :desc, created_at: :desc).limit(SUPPORT_CONTEXT_LIMIT)
  end

  def recent_products
    @recent_products ||= @user.products.not_wip.includes(:practice, :checks, :checker).order(published_at: :desc, id: :desc).limit(SUPPORT_CONTEXT_LIMIT)
  end

  def recent_questions
    @recent_questions ||= @user.questions.not_wip
                               .includes(:practice, :answers, :correct_answer)
                               .order(updated_at: :desc, id: :desc)
                               .limit(SUPPORT_CONTEXT_LIMIT)
  end

  def recent_mentor_memos
    @recent_mentor_memos ||= @user.mentor_memos.order(created_at: :desc).limit(SUPPORT_CONTEXT_LIMIT)
  end

  def practice_json(practice)
    {
      id: practice.id,
      title: practice.title
    }
  end

  def report_json(report)
    {
      id: report.id,
      title: report.title,
      reported_on: report.reported_on,
      wip: report.wip?,
      checked: report.checked?,
      updated_at: report.updated_at
    }
  end

  def mentor_memo_json(mentor_memo)
    {
      id: mentor_memo.id,
      content: mentor_memo.content,
      author: mentor_memo.author && "#{mentor_memo.author.login_name} (#{mentor_memo.author.name_kana})",
      created_at: mentor_memo.created_at
    }
  end

  def product_json(product)
    {
      id: product.id,
      practice: practice_json(product.practice),
      body: product.body,
      checked: product.checked?,
      checker_id: product.checker_id,
      commented_at: product.commented_at,
      published_at: product.published_at,
      updated_at: product.updated_at
    }
  end

  def question_json(question)
    {
      id: question.id,
      title: question.title,
      practice: question.practice && practice_json(question.practice),
      solved: question.correct_answer.present?,
      answers_count: question.answers.size,
      published_at: question.published_at,
      updated_at: question.updated_at
    }
  end

  def talk_json
    talk = @user.talk
    return unless talk

    {
      id: talk.id,
      action_completed: talk.action_completed,
      comments_count: talk.comments.size,
      updated_at: talk.updated_at
    }
  end

  def learning_progress_json
    user_course_practice = UserCoursePractice.new(@user)
    required_practices_count = user_course_practice.required_practices.size
    completed_practices_count = user_course_practice.completed_required_practices.size
    {
      completed_practices_count:,
      required_practices_count:,
      completed_percentage: completed_percentage(completed_practices_count, required_practices_count)
    }
  end

  def completed_percentage(completed_practices_count, required_practices_count)
    return 0.0 unless required_practices_count.positive?

    (completed_practices_count.to_f / required_practices_count * 100).round(1)
  end
end
