# frozen_string_literal: true

require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test 'creates report after removing null bytes from title and description' do
    assert_difference -> { users(:kimura).reports.count }, 1 do
      post reports_path(_login_name: 'kimura'), params: {
        report: {
          title: "NULL\u0000バイトを含むタイトル",
          description: "NULL\u0000バイトを含む本文",
          reported_on: Date.current.to_s,
          emotion: 'positive',
          no_learn: '1'
        }
      }
    end

    report = users(:kimura).reports.find_by!(reported_on: Date.current)
    assert_redirected_to report_path(report)
    assert_equal 'NULLバイトを含むタイトル', report.title
    assert_equal 'NULLバイトを含む本文', report.description
  end

  test 'updates report after removing null bytes from title and description' do
    report = reports(:report24)

    patch report_path(report, _login_name: 'kimura'), params: {
      report: {
        title: "更新した\u0000タイトル",
        description: "更新した\u0000本文",
        reported_on: report.reported_on.to_s,
        emotion: report.emotion,
        no_learn: '1'
      }
    }

    assert_redirected_to report_path(report)
    report.reload
    assert_equal '更新したタイトル', report.title
    assert_equal '更新した本文', report.description
  end

  test 'mentor can manually create report comment by Pjord' do
    report = reports(:report5)
    report.user.update_column(:pjord_comment, false) # rubocop:disable Rails/SkipsModelValidations

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'general' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'コメント本文') do
        assert_no_enqueued_jobs only: PjordReportCommentJob do
          assert_difference -> { report.comments.where(user: users(:pjord)).count }, 1 do
            post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
          end
        end
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドがコメントしました。', flash[:notice]
    assert_equal 'コメント本文', report.comments.order(:created_at).last.description
  end

  test 'admin can manually create report comment by Pjord' do
    report = reports(:report5)

    Pjord::ReportClassifierAgent.stub(:classify, { intent: 'general' }) do
      Pjord::ReportCommentAgent.stub(:comment, 'コメント本文') do
        assert_no_enqueued_jobs only: PjordReportCommentJob do
          assert_difference -> { report.comments.where(user: users(:pjord)).count }, 1 do
            post comment_by_pjord_report_path(report, _login_name: 'adminonly')
          end
        end
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドがコメントしました。', flash[:notice]
    assert_equal 'コメント本文', report.comments.order(:created_at).last.description
  end

  test 'redirects with alert when Pjord report comment fails' do
    report = reports(:report5)

    PjordReportCommentJob.stub(:perform_now, ->(report_id:) { raise StandardError, report_id }) do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドのコメントに失敗しました。時間をおいて再度お試しください。', flash[:alert]
  end

  test 'redirects with alert when Pjord report comment API key is invalid' do
    report = reports(:report5)

    PjordReportCommentJob.stub(:perform_now, lambda { |_args|
      raise RubyLLM::UnauthorizedError, 'invalid x-api-key'
    }) do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(report, _login_name: 'mentormentaro')
      end
    end

    assert_redirected_to report_path(report)
    assert_equal 'ピヨルドのAPIキー設定が無効です。管理者に確認してください。', flash[:alert]
  end

  test 'student cannot manually create report comment by Pjord' do
    assert_no_enqueued_jobs only: PjordReportCommentJob do
      assert_no_difference 'Comment.count' do
        post comment_by_pjord_report_path(reports(:report5), _login_name: 'kimura')
      end
    end
  end

  test 'show issues the same number of queries regardless of the number of comments, reactions, footprints and products' do
    user = users(:with_hyphen)
    report = user.reports.order(:reported_on).last
    setup_report_page_records(report)

    many = count_queries { get report_path(report, _login_name: 'mentormentaro') }
    assert_response :ok

    trim_report_page_records(report)

    few = count_queries { get report_path(report, _login_name: 'mentormentaro') }
    assert_response :ok
    assert_equal few, many
  end

  private

  # アバターを持つユーザーは、テスト環境では表示のたびにアバターの付け替えを試みてSQL回数が変わるため使わない。
  def report_page_viewers
    [users(:kimura), users(:hajime), users(:sotugyou)]
  end

  def setup_report_page_records(report)
    products = report.user.products.not_wip.limit(20).to_a
    recent_reports = Report.list.where(user_id: report.user_id).limit(10).to_a
    insert_report_page_comments([report] * 4 + products + recent_reports)
    insert_report_page_reactions(report.comments)
    insert_report_page_checks(products + recent_reports)
    report_page_viewers.each { |viewer| Footprint.find_or_create_by!(user: viewer, footprintable: report) }
    get report_path(report, _login_name: 'mentormentaro') # キャッシュなど初回だけの処理を済ませる
  end

  def insert_report_page_comments(commentables)
    now = Time.current
    comments = commentables.flat_map.with_index do |commentable, i|
      report_page_viewers.map.with_index do |viewer, j|
        { user_id: viewer.id, commentable_type: commentable.class.name, commentable_id: commentable.id,
          description: 'コメント', created_at: now + i + j, updated_at: now + i + j }
      end
    end
    Comment.insert_all!(comments) # rubocop:disable Rails/SkipsModelValidations
  end

  def insert_report_page_reactions(comments)
    now = Time.current
    reactions = comments.flat_map do |comment|
      report_page_viewers.map do |viewer|
        { user_id: viewer.id, reactionable_type: 'Comment', reactionable_id: comment.id, kind: 0, created_at: now, updated_at: now }
      end
    end
    Reaction.insert_all!(reactions) # rubocop:disable Rails/SkipsModelValidations
  end

  def insert_report_page_checks(checkables)
    now = Time.current
    checks = checkables.reject { |checkable| checkable.checks.exists? }.map do |checkable|
      { user_id: users(:sotugyou).id, checkable_type: checkable.class.name, checkable_id: checkable.id, created_at: now, updated_at: now }
    end
    Check.insert_all!(checks) # rubocop:disable Rails/SkipsModelValidations
  end

  def trim_report_page_records(report)
    user = report.user
    kept_product = user.products.not_wip.order(published_at: :desc).first
    user.products.where.not(id: kept_product.id).find_each(&:destroy!)
    kept_comment = report.comments.order(:created_at).first
    report.comments.where.not(id: kept_comment.id).delete_all
    Footprint.where(footprintable: report).where.not(user: users(:mentormentaro)).order(:id).offset(1).delete_all
    Reaction.where(reactionable: kept_comment).order(:id).offset(1).delete_all
    Report.where(user:).where.not(id: report.id).find_each do |other_report|
      other_report.comments.order(:id).offset(1).delete_all
    end
  end

  def count_queries(&)
    count = 0
    counter = lambda do |*, payload|
      count += 1 unless payload[:name].in?(%w[SCHEMA TRANSACTION])
    end
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &)
    count
  end
end
