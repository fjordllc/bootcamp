# frozen_string_literal: true

require 'test_helper'

class SearcherTest < ActiveSupport::TestCase
  SEARCHABLE_CLASSES = [Report, Page, Practice, Question, Announcement, Event, RegularEvent, Comment, Answer, CorrectAnswer, User].freeze

  def assert_includes_classes(results, *expected_classes)
    actual_classes = results.map(&:class).map(&:name).uniq
    expected_classes.each do |klass|
      assert_includes actual_classes, klass.name
    end
    not_expected_classes = SEARCHABLE_CLASSES - expected_classes
    not_expected_classes.each do |klass|
      assert_not_includes actual_classes, klass.name
    end
  end

  def current_user
    users(:kimura)
  end

  # キーワード検索結果の強調されているHTMLタグを除去するヘルパーメソッド
  def strip_html(text)
    ActionController::Base.helpers.strip_tags(text)
  end

  test 'returns results for all types when no user filter is applied' do
    results = Searcher.new(keyword: 'テスト', document_type: :all, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report page practice question announcement event regular_event comment answer correct_answer user]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'filters results by user when user filter is applied' do
    results = Searcher.new(keyword: 'テスト', document_type: :all, only_me: true, current_user:).search
    results.each do |result|
      assert_equal current_user.id, result.user_id if result.user_id
    end
  end

  test 'filters results based on user visibility' do
    result = Searcher.new(keyword: '相談部屋', document_type: :all, only_me: false, current_user:).search
    assert_equal 0, result.size
    admin_user = users(:komagata)
    result_admin = Searcher.new(keyword: '相談部屋', document_type: :all, only_me: false, current_user: admin_user).search
    assert_empty result_admin
  end

  test 'returns results filtered by user' do
    results = Searcher.new(keyword: 'テスト', document_type: :report, only_me: true, current_user:).search
    results.each do |result|
      assert_equal current_user.id, result.user_id if result.user_id
    end
  end

  test 'filters results by all keywords' do
    result = Searcher.new(keyword: 'OS クリーンインストール', document_type: :practice, only_me: false, current_user:).search
    titles = result.map(&:title)
    assert_includes titles, practices(:practice1).title
    assert_not_includes titles, practices(:practice3).title
  end

  test "returns all types when document_type argument isn't specified" do
    results = Searcher.new(keyword: 'テスト', document_type: :all, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report page practice question announcement event regular_event comment answer correct_answer user]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns all types when document_type argument is :all' do
    results = Searcher.new(keyword: 'テスト', document_type: :all, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report page practice question announcement event regular_event comment answer correct_answer user]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only report type when document_type argument is :report' do
    results = Searcher.new(keyword: 'テスト', document_type: :report, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only page type when document_type argument is :page' do
    results = Searcher.new(keyword: 'テスト', document_type: :page, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['page']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only practice type when document_type argument is :practice' do
    results = Searcher.new(keyword: 'テスト', document_type: :practice, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['practice']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only question type when document_type argument is :question' do
    results = Searcher.new(keyword: 'テスト', document_type: :question, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[question answer correct_answer]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :announcement' do
    results = Searcher.new(keyword: 'テスト', document_type: :announcement, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[announcement comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :event' do
    results = Searcher.new(keyword: 'テスト', document_type: :event, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[event comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :regular_event' do
    results = Searcher.new(keyword: 'テスト', document_type: :regular_event, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[regular_event comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :user' do
    results = Searcher.new(keyword: 'テスト', document_type: :user, only_me: false, current_user:).search
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['user']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'sort search results in descending order of updated date' do
    result = Searcher.new(keyword: '検索結果確認用', document_type: :report, only_me: false, current_user:).search
    titles = result.map(&:title)

    assert_equal [reports(:report12).title, reports(:report14).title, reports(:report13).title], titles
    assert_not_includes(result, Answer)
  end

  test 'returns only reports having all keywords' do
    result = Searcher.new(keyword: '日報', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.new(keyword: '日報 WIP', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.new(keyword: '日報　WIP', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])
  end

  test 'returns only pages having all keywords' do
    result = Searcher.new(keyword: 'テスト', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.new(keyword: 'テスト Bootcamp', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.new(keyword: 'テスト　Bootcamp', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])
  end

  test 'returns only practices having all keywords' do
    result = Searcher.new(keyword: 'OS', document_type: :practice, only_me: false, current_user:).search
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_includes(titles, practices(:practice3).title)

    result = Searcher.new(keyword: 'OS クリーンインストール', document_type: :practice, only_me: false, current_user:).search
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_not_includes(titles, practices(:practice3).title)

    result = Searcher.new(keyword: 'OS　クリーンインストール', document_type: :practice, only_me: false, current_user:).search
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_not_includes(titles, practices(:practice3).title)
  end

  test 'returns only questions having all keywords' do
    result = Searcher.new(keyword: '使う', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])

    result = Searcher.new(keyword: '使う エディター', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])

    result = Searcher.new(keyword: '使う　エディター', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])
  end

  test 'returns only answers of questions having all keywords' do
    result = Searcher.new(keyword: 'です', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])

    result = Searcher.new(keyword: 'です atom', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])
    result = Searcher.new(keyword: 'です　atom', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])
  end

  test 'returns only announcements having all keywords' do
    result = Searcher.new(keyword: 'お知らせ', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])

    result = Searcher.new(keyword: 'お知らせ 通知', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])

    result = Searcher.new(keyword: 'お知らせ　通知', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
  end

  test 'returns only comments having all keywords' do
    result = Searcher.new(keyword: 'report_id', document_type: :report, only_me: false, current_user:).search
    actual_results = result.map { |r| [strip_html(r.formatted_summary).strip.gsub('`', ''), r.login_name] }
    assert_includes(actual_results, [strip_html(comments(:comment6).description).strip.gsub('`', ''), comments(:comment6).user.login_name])
    assert_includes(actual_results, [strip_html(comments(:comment5).description).strip.gsub('`', ''), comments(:comment5).user.login_name])

    result = Searcher.new(keyword: 'report_id typo', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.formatted_summary), r.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])

    result = Searcher.new(keyword: 'report_id　typo', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.formatted_summary), r.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])
  end

  test 'returns only comments associated to specified document_type' do
    result = Searcher.new(keyword: 'コメント', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment11).description, comments(:comment11).user.login_name])
  end

  test 'returns all comments when document_type is not specified' do
    current_user = users(:komagata)
    result = Searcher.new(keyword: 'コメント', document_type: :all, only_me: false, current_user:).search
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [comments(:comment8).description, comments(:comment8).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment10).description, comments(:comment10).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment11).description, comments(:comment11).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment12).description, comments(:comment12).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment13).description, comments(:comment13).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment14).description, comments(:comment14).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment16).description, comments(:comment16).user.login_name])
    assert_equal(31, result.size)
  end

  test 'can not search a comment of talk' do
    assert_equal 0, Searcher.new(keyword: '相談部屋', document_type: :all, only_me: false, current_user:).search.size
  end

  # 新しいKeywordSearchでは、user:形式ではなくonly_meフラグを使用する
  test 'returns only current users content when only_me is true' do
    current_user = users(:kimura)
    result = Searcher.new(keyword: 'ユーザーネームで検索できるよ', document_type: :all, only_me: true, current_user:).search
    result.each do |item|
      assert_equal current_user.id, item.user_id if item.user_id
    end
  end

  test 'search only myself' do
    current_user = users(:komagata)

    my_reports = Searcher.new(keyword: 'テスト', document_type: :report, only_me: true, current_user:).search
    assert(my_reports.all? { |searchable| searchable.user_id == current_user.id && searchable.summary.include?('テスト') })

    # 検索結果にPracticeとUserを含まないことを確認
    all_my_results = Searcher.new(keyword: '', document_type: :all, only_me: true, current_user:).search
    assert(all_my_results.all? { |result| !result.class.name.in?(%w[Practice User]) })
  end

  test 'available_types returns all configured types' do
    expected_types = %i[practice user report product announcement page question answer correct_answer comment event regular_event]
    assert_equal expected_types.sort, Searcher.available_types.sort
  end

  test 'validates document_type parameter' do
    # Valid types should work
    assert_nothing_raised do
      Searcher.new(keyword: 'test', document_type: :report, current_user:)
    end

    assert_nothing_raised do
      Searcher.new(keyword: 'test', document_type: :all, current_user:)
    end

    # Invalid type should raise error
    assert_raises ArgumentError do
      Searcher.new(keyword: 'test', document_type: :invalid_type, current_user:)
    end

    # String types should work too
    assert_nothing_raised do
      Searcher.new(keyword: 'test', document_type: 'report', current_user:)
    end
  end
end
