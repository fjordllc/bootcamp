# frozen_string_literal: true

require 'test_helper'

class SearcherTest < ActiveSupport::TestCase
  include SearchHelper
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
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Report Page Practice Question Announcement Event RegularEvent Comment Answer CorrectAnswer User]
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
    results = Searcher.new(keyword: '検索', document_type: :report, only_me: true, current_user:).search
    assert_not_empty results, 'Results should not be empty'
    results.each do |result|
      assert_equal current_user.id, result.user_id if result.user_id
    end
  end

  test 'filters results by all keywords' do
    result = Searcher.new(keyword: 'OS クリーンインストール', document_type: :practice, only_me: false, current_user:).search
    titles = result.map(&:search_title)
    assert_includes titles, practices(:practice1).title
    assert_not_includes titles, practices(:practice3).title
  end

  test "returns all types when document_type argument isn't specified" do
    results = Searcher.new(keyword: 'テスト', document_type: :all, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Report Page Practice Question Announcement Event RegularEvent Comment Answer CorrectAnswer User]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns all types when document_type argument is :all' do
    results = Searcher.new(keyword: 'テスト', document_type: :all, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Report Page Practice Question Announcement Event RegularEvent Comment Answer CorrectAnswer User]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only report type when document_type argument is :report' do
    results = Searcher.new(keyword: 'テスト', document_type: :report, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Report Comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only page type when document_type argument is :page' do
    results = Searcher.new(keyword: 'テスト', document_type: :page, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = ['Page']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only practice type when document_type argument is :practice' do
    results = Searcher.new(keyword: 'テスト', document_type: :practice, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = ['Practice']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only question type when document_type argument is :question' do
    results = Searcher.new(keyword: 'テスト', document_type: :question, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Question Answer CorrectAnswer]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :announcement' do
    results = Searcher.new(keyword: 'テスト', document_type: :announcement, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Announcement Comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :event' do
    results = Searcher.new(keyword: 'テスト', document_type: :event, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[Event Comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :regular_event' do
    results = Searcher.new(keyword: 'テスト', document_type: :regular_event, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = %w[RegularEvent Comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :user' do
    results = Searcher.new(keyword: 'テスト', document_type: :user, only_me: false, current_user:).search
    actual_classes = results.map { |r| r.class.name }.uniq
    expected_classes = ['User']
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
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [reports(:report9).title, reports(:report9).user.login_name])
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.new(keyword: '日報 WIP', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.new(keyword: '日報　WIP', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [reports(:report8).title, reports(:report8).user.login_name])
  end

  test 'returns only pages having all keywords' do
    result = Searcher.new(keyword: 'テスト', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      if r.is_a?(User)
                        [r.name, r.login_name]
                      else
                        [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                      end
                    end, [pages(:page4).title, pages(:page4).user.login_name])
    assert_includes(result.map do |r|
                      if r.is_a?(User)
                        [r.name, r.login_name]
                      else
                        [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                      end
                    end, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.new(keyword: 'テスト Bootcamp', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.new(keyword: 'テスト　Bootcamp', document_type: :page, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [pages(:page3).title, pages(:page3).user.login_name])
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
    assert_includes(result.map do |r|
                      if r.is_a?(User)
                        [r.name, r.login_name]
                      else
                        [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                      end
                    end, [questions(:question2).title, questions(:question2).user.login_name])
    assert_includes(result.map do |r|
                      if r.is_a?(User)
                        [r.name, r.login_name]
                      else
                        [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                      end
                    end, [questions(:question1).title, questions(:question1).user.login_name])

    result = Searcher.new(keyword: '使う エディター', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [questions(:question2).title, questions(:question2).user.login_name])

    result = Searcher.new(keyword: '使う　エディター', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [questions(:question2).title, questions(:question2).user.login_name])
  end

  test 'returns only answers of questions having all keywords' do
    result = Searcher.new(keyword: 'です', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [answers(:answer5).description, answers(:answer5).user.login_name])

    result = Searcher.new(keyword: 'です atom', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [answers(:answer5).description, answers(:answer5).user.login_name])
    result = Searcher.new(keyword: 'です　atom', document_type: :question, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [answers(:answer5).description, answers(:answer5).user.login_name])
  end

  test 'returns only announcements having all keywords' do
    result = Searcher.new(keyword: 'お知らせ', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])

    result = Searcher.new(keyword: 'お知らせ 通知', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])

    result = Searcher.new(keyword: 'お知らせ　通知', document_type: :announcement, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map do |r|
                          [r.is_a?(User) ? r.name : r.title, r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
  end

  test 'returns only comments having all keywords' do
    result = Searcher.new(keyword: 'report_id', document_type: :report, only_me: false, current_user:).search
    actual_results = result.map { |r| [strip_html(r.description).strip.delete('`'), r.is_a?(User) ? r.login_name : r.user.login_name] }
    assert_includes(actual_results, [strip_html(comments(:comment6).description).strip.delete('`'), comments(:comment6).user.login_name])
    assert_includes(actual_results, [strip_html(comments(:comment5).description).strip.delete('`'), comments(:comment5).user.login_name])

    result = Searcher.new(keyword: 'report_id typo', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])

    result = Searcher.new(keyword: 'report_id　typo', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])
  end

  test 'returns only comments associated to specified document_type' do
    result = Searcher.new(keyword: 'コメント', document_type: :report, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment11).description, comments(:comment11).user.login_name])
  end

  test 'returns all comments when document_type is not specified' do
    current_user = users(:komagata)
    result = Searcher.new(keyword: 'コメント', document_type: :all, only_me: false, current_user:).search
    assert_includes(result.map do |r|
                      if r.is_a?(User)
                        [strip_html(r.description), r.login_name]
                      else
                        [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                      end
                    end, [comments(:comment8).description, comments(:comment8).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment10).description, comments(:comment10).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment11).description, comments(:comment11).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment12).description, comments(:comment12).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment13).description, comments(:comment13).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
                    end, [comments(:comment14).description, comments(:comment14).user.login_name])
    assert_includes(result.map do |r|
                      [strip_html(r.description), r.is_a?(User) ? r.login_name : r.user.login_name]
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
    assert(my_reports.all? { |searchable| searchable.user_id == current_user.id && searchable.description.include?('テスト') })

    # 検索結果にPracticeとUserを含まないことを確認
    all_my_results = Searcher.new(keyword: '', document_type: :all, only_me: true, current_user:).search
    assert(all_my_results.all? { |result| !result.class.name.in?(%w[Practice User]) })
  end

  test 'available_types returns all configured types' do
    expected_types = %i[practice user report product announcement page question answer correct_answer comment event regular_event]
    assert_equal expected_types.sort, Searcher::Configuration.available_types.sort
  end

  test 'empty keyword returns empty results' do
    result = Searcher.new(keyword: '', document_type: :user, only_me: false, current_user:).search
    assert_empty result

    result = Searcher.new(keyword: '   ', document_type: :all, only_me: false, current_user:).search
    assert_empty result
  end

  test 'split_keywords splits text by whitespace' do
    result = Searcher.split_keywords('ruby rails javascript')
    assert_equal %w[ruby rails javascript], result
  end

  test 'split_keywords handles multiple whitespace types' do
    result = Searcher.split_keywords("ruby\trails   javascript")
    assert_equal %w[ruby rails javascript], result
  end

  test 'split_keywords handles empty string' do
    result = Searcher.split_keywords('')
    assert_empty result
  end

  test 'split_keywords handles nil input' do
    result = Searcher.split_keywords(nil)
    assert_empty result
  end

  test 'split_keywords removes blank entries' do
    result = Searcher.split_keywords('  ruby    rails  ')
    assert_equal %w[ruby rails], result
  end

  test 'split_keywords handles Japanese whitespace' do
    result = Searcher.split_keywords('日本語　テスト　キーワード')
    assert_equal %w[日本語 テスト キーワード], result
  end

  test 'attr_readers return correct values' do
    searcher = Searcher.new(keyword: 'test keyword', current_user:, document_type: :page, only_me: true)

    assert_equal 'test keyword', searcher.keyword
    assert_equal :page, searcher.document_type
    assert_equal current_user, searcher.current_user
    assert searcher.only_me
  end

  test 'initialize strips keyword whitespace' do
    searcher = Searcher.new(keyword: '  test keyword  ', current_user:)

    assert_equal 'test keyword', searcher.keyword
  end

  test 'initialize converts keyword to string' do
    searcher = Searcher.new(keyword: nil, current_user:)

    assert_equal '', searcher.keyword
  end

  test 'initialize sets default values' do
    searcher = Searcher.new(keyword: 'test', current_user:)

    assert_equal :all, searcher.document_type
    assert_not searcher.only_me
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

  test 'search_label returns text label for all resources including User' do
    user = users(:komagata)
    report = reports(:report1)

    # User should return text label, not avatar_url
    user_label = user.search_label
    assert_instance_of String, user_label
    assert_no_match(/http/, user_label) # Should not contain URL

    # Other resources should also return text labels
    report_label = report.search_label
    assert_instance_of String, report_label
  end

  test 'search_thumbnail returns avatar_url for User and nil for others' do
    user = users(:komagata)
    report = reports(:report1)

    # User should return avatar_url
    user_thumbnail = user.search_thumbnail
    assert_match(/http/, user_thumbnail) # Should contain URL

    # Other resources should return nil
    report_thumbnail = report.search_thumbnail
    assert_nil report_thumbnail
  end

  test 'return not retired user data' do
    hajime = users(:hajime)
    searcher = Searcher.new(keyword: hajime.name, current_user: hajime, document_type: :user)
    result = searcher.search
    assert_includes(result, hajime)
  end

  test 'columns_for_keyword_searchの設定がSearcherに反映されていることを確認' do
    komagata = users(:komagata)
    komagata.discord_profile.account_name = 'komagata1234'
    komagata.update!(login_name: 'komagata1234',
                     name: 'こまがた1234',
                     name_kana: 'コマガタイチニサンヨン',
                     twitter_account: 'komagata1234_tw',
                     facebook_url: 'http://www.facebook.com/komagata1234',
                     blog_url: 'http://komagata1234.org',
                     github_account: 'komagata1234_github',
                     description: '平日１０〜１９時勤務です。1234')

    searcher = Searcher.new(keyword: komagata.login_name, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.name, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.name_kana, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.twitter_account, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.facebook_url, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.blog_url, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.github_account, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)

    searcher = Searcher.new(keyword: komagata.discord_profile.account_name, current_user: komagata, document_type: :user)
    assert_includes(searcher.search, komagata)
  end
end
