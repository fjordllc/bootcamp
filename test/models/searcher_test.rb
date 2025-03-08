# frozen_string_literal: true

require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
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

  test "returns all types when document_type argument isn't specified" do
    results = Searcher.search('テスト', current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report page practice question announcement event regular_event comment answer correct_answer user]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns all types when document_type argument is :all' do
    results = Searcher.search('テスト', document_type: :all, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report page practice question announcement event regular_event comment answer correct_answer user]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only report type when document_type argument is :reports' do
    results = Searcher.search('テスト', document_type: :reports, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[report comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only page type when document_type argument is :pages' do
    results = Searcher.search('テスト', document_type: :pages, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['page']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only practice type when document_type argument is :practices' do
    results = Searcher.search('テスト', document_type: :practices, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['practice']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only question type when document_type argument is :questions' do
    results = Searcher.search('テスト', document_type: :questions, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[question answer correct_answer]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :announcements' do
    results = Searcher.search('テスト', document_type: :announcements, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[announcement comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :events' do
    results = Searcher.search('テスト', document_type: :events, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[event comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only event type when document_type argument is :regular_events' do
    results = Searcher.search('テスト', document_type: :regular_events, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = %w[regular_event comment]
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'returns only announcement type when document_type argument is :users' do
    results = Searcher.search('テスト', document_type: :users, current_user:)
    actual_classes = results.map(&:model_name).uniq
    expected_classes = ['user']
    expected_classes.each do |klass|
      assert_includes actual_classes, klass
    end
  end

  test 'sort search results in descending order of updated date' do
    result = Searcher.search('検索結果確認用', document_type: :reports, current_user:)
    titles = result.map(&:title)

    assert_equal [reports(:report12).title, reports(:report14).title, reports(:report13).title], titles
    assert_not_includes(result, Answer)
  end

  test 'returns only reports having all keywords' do
    result = Searcher.search('日報', document_type: :reports, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.search('日報 WIP', document_type: :reports, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])

    result = Searcher.search('日報　WIP', document_type: :reports, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report9).title, reports(:report9).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report8).title, reports(:report8).user.login_name])
  end

  test 'returns only pages having all keywords' do
    result = Searcher.search('テスト', document_type: :pages, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.search('テスト Bootcamp', document_type: :pages, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])

    result = Searcher.search('テスト　Bootcamp', document_type: :pages, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page4).title, pages(:page4).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [pages(:page3).title, pages(:page3).user.login_name])
  end

  test 'returns only practices having all keywords' do
    result = Searcher.search('OS', document_type: :practices, current_user:)
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_includes(titles, practices(:practice3).title)

    result = Searcher.search('OS クリーンインストール', document_type: :practices, current_user:)
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_not_includes(titles, practices(:practice3).title)

    result = Searcher.search('OS　クリーンインストール', document_type: :practices, current_user:)
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice1).title)
    assert_not_includes(titles, practices(:practice3).title)
  end

  test 'returns only questions having all keywords' do
    result = Searcher.search('使う', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])

    result = Searcher.search('使う エディター', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])

    result = Searcher.search('使う　エディター', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question1).title, questions(:question1).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [questions(:question2).title, questions(:question2).user.login_name])
  end

  test 'returns only answers of questions having all keywords' do
    result = Searcher.search('です', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])

    result = Searcher.search('です atom', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])
    result = Searcher.search('です　atom', document_type: :questions, current_user:)
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer1).description, answers(:answer1).user.login_name])
    assert_not_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [answers(:answer5).description, answers(:answer5).user.login_name])
  end

  test 'returns only announcements having all keywords' do
    result = Searcher.search('お知らせ', document_type: :announcements, current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])

    result = Searcher.search('お知らせ 通知', document_type: :announcements, current_user:)
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])

    result = Searcher.search('お知らせ　通知', document_type: :announcements, current_user:)
    assert_includes(result.map do |r|
                      [r.title, r.login_name]
                    end, [announcements(:announcement_notification_active_user).title, announcements(:announcement_notification_active_user).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [announcements(:announcement3).title, announcements(:announcement3).user.login_name])
  end

  test 'returns only comments having all keywords' do
    result = Searcher.search('report_id', document_type: :reports, current_user:)
    actual_results = result.map { |r| [strip_html(r.formatted_summary).strip.gsub('`', ''), r.login_name] }
    assert_includes(actual_results, [strip_html(comments(:comment6).description).strip.gsub('`', ''), comments(:comment6).user.login_name])
    assert_includes(actual_results, [strip_html(comments(:comment5).description).strip.gsub('`', ''), comments(:comment5).user.login_name])

    result = Searcher.search('report_id typo', document_type: :reports, current_user:)
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.formatted_summary), r.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])

    result = Searcher.search('report_id　typo', document_type: :reports, current_user:)
    assert_includes(result.map { |r| [strip_html(r.formatted_summary), r.login_name] }, [comments(:comment6).description, comments(:comment6).user.login_name])
    assert_not_includes(result.map do |r|
                          [strip_html(r.formatted_summary), r.login_name]
                        end, [comments(:comment5).description, comments(:comment5).user.login_name])
  end

  test 'returns only comments associated to specified document_type' do
    result = Searcher.search('コメント', document_type: :reports, current_user:)
    assert_includes(result.map do |r|
                      [strip_html(r.formatted_summary), r.login_name]
                    end, [comments(:comment11).description, comments(:comment11).user.login_name])
  end

  test 'returns all comments when document_type is not specified' do
    current_user = users(:komagata)
    result = Searcher.search('コメント', current_user:)
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
    assert_equal 0, Searcher.search('相談部屋', current_user:).size
  end

  test 'returns only kimuras report when user param' do
    result = Searcher.search('ユーザーネームで検索できるよ user:kimura', current_user:)
    assert_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report24).title, reports(:report24).user.login_name])
    assert_not_includes(result.map { |r| [r.title, r.login_name] }, [reports(:report25).title, reports(:report25).user.login_name])
  end

  test 'returns only updated-by-komagata practice when user param' do
    result = Searcher.search('ユーザーネーム（最終更新者）で検索できるよ user:komagata', current_user:)
    titles = result.map(&:title)
    assert_includes(titles, practices(:practice55).title)
    assert_not_includes(titles, practices(:practice56).title)
  end
end
