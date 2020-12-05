# frozen_string_literal: true

require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  test "returns all types when document_type argument isn't specified" do
    result = Searcher.search('テスト').map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
    assert_includes(result, Comment)
    assert_includes(result, Answer)
  end

  test 'returns all types when document_type argument is :all' do
    result = Searcher.search('テスト', document_type: :all).map(&:class)
    assert_includes(result, Report)
    assert_includes(result, Page)
    assert_includes(result, Practice)
    assert_includes(result, Question)
    assert_includes(result, Announcement)
    assert_includes(result, Comment)
    assert_includes(result, Answer)
  end

  test 'returns only report type when document_type argument is :reports' do
    result = Searcher.search('テスト', document_type: :reports).map(&:class)
    assert_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
    assert_includes(result, Comment)
    assert_not_includes(result, Answer)
  end

  test 'returns only page type when document_type argument is :pages' do
    result = Searcher.search('テスト', document_type: :pages).map(&:class)
    assert_not_includes(result, Report)
    assert_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
    assert_not_includes(result, Comment)
    assert_not_includes(result, Answer)
  end

  test 'returns only practice type when document_type argument is :practices' do
    result = Searcher.search('テスト', document_type: :practices).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_not_includes(result, Announcement)
    assert_not_includes(result, Comment)
    assert_not_includes(result, Answer)
  end

  test 'returns only question type when document_type argument is :questions' do
    result = Searcher.search('テスト', document_type: :questions).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_includes(result, Question)
    assert_not_includes(result, Announcement)
    assert_not_includes(result, Comment)
    assert_includes(result, Answer)
  end

  test 'returns only announcement type when document_type argument is :announcements' do
    result = Searcher.search('テスト', document_type: :announcements).map(&:class)
    assert_not_includes(result, Report)
    assert_not_includes(result, Page)
    assert_not_includes(result, Practice)
    assert_not_includes(result, Question)
    assert_includes(result, Announcement)
    assert_includes(result, Comment)
  end

  test 'sort search results in descending order of updated date' do
    result = Searcher.search('検索結果確認用', document_type: :reports)
    assert_equal [reports(:report_14), reports(:report_13), reports(:report_12)], result
    assert_not_includes(result, Answer)
  end

  test 'returns only reports having all keywords' do
    result = Searcher.search('日報', document_type: :reports)
    assert_includes(result, reports(:report_9))
    assert_includes(result, reports(:report_8))

    result = Searcher.search('日報 WIP', document_type: :reports)
    assert_includes(result, reports(:report_9))
    assert_not_includes(result, reports(:report_8))

    result = Searcher.search('日報　WIP', document_type: :reports)
    assert_includes(result, reports(:report_9))
    assert_not_includes(result, reports(:report_8))
  end

  test 'returns only pages having all keywords' do
    result = Searcher.search('テスト', document_type: :pages)
    assert_includes(result, pages(:page_4))
    assert_includes(result, pages(:page_3))

    result = Searcher.search('テスト Bootcamp', document_type: :pages)
    assert_includes(result, pages(:page_4))
    assert_not_includes(result, pages(:page_3))

    result = Searcher.search('テスト　Bootcamp', document_type: :pages)
    assert_includes(result, pages(:page_4))
    assert_not_includes(result, pages(:page_3))
  end

  test 'returns only practices having all keywords' do
    result = Searcher.search('OS', document_type: :practices)
    assert_includes(result, practices(:practice_1))
    assert_includes(result, practices(:practice_3))

    result = Searcher.search('OS クリーンインストール', document_type: :practices)
    assert_includes(result, practices(:practice_1))
    assert_not_includes(result, practices(:practice_3))

    result = Searcher.search('OS　クリーンインストール', document_type: :practices)
    assert_includes(result, practices(:practice_1))
    assert_not_includes(result, practices(:practice_3))
  end

  test 'returns only questions having all keywords' do
    result = Searcher.search('使う', document_type: :questions)
    assert_includes(result, questions(:question_2))
    assert_includes(result, questions(:question_1))

    result = Searcher.search('使う エディター', document_type: :questions)
    assert_includes(result, questions(:question_1))
    assert_not_includes(result, questions(:question_2))

    result = Searcher.search('使う　エディター', document_type: :questions)
    assert_includes(result, questions(:question_1))
    assert_not_includes(result, questions(:question_2))
  end

  test 'returns only answers of questions having all keywords' do
    result = Searcher.search('です', document_type: :questions)
    assert_includes(result, answers(:answer_1))
    assert_includes(result, answers(:answer_5))

    result = Searcher.search('です atom', document_type: :questions)
    assert_includes(result, answers(:answer_1))
    assert_not_includes(result, answers(:answer_5))

    result = Searcher.search('です　atom', document_type: :questions)
    assert_includes(result, answers(:answer_1))
    assert_not_includes(result, answers(:answer_5))
  end

  test 'returns only announcements having all keywords' do
    result = Searcher.search('お知らせ', document_type: :announcements)
    assert_includes(result, announcements(:announcement_3))
    assert_includes(result, announcements(:announcement_notification_active_user))

    result = Searcher.search('お知らせ 通知', document_type: :announcements)
    assert_includes(result, announcements(:announcement_notification_active_user))
    assert_not_includes(result, announcements(:announcement_3))

    result = Searcher.search('お知らせ　通知', document_type: :announcements)
    assert_includes(result, announcements(:announcement_notification_active_user))
    assert_not_includes(result, announcements(:announcement_3))
  end

  test 'returns only comments having all keywords' do
    result = Searcher.search('report_id', document_type: :reports)
    assert_includes(result, comments(:comment_6))
    assert_includes(result, comments(:comment_5))

    result = Searcher.search('report_id typo', document_type: :reports)
    assert_includes(result, comments(:comment_6))
    assert_not_includes(result, comments(:comment_5))

    result = Searcher.search('report_id　typo', document_type: :reports)
    assert_includes(result, comments(:comment_6))
    assert_not_includes(result, comments(:comment_5))
  end

  test 'returns only comments associated to specified document_type' do
    result = Searcher.search('コメント', document_type: :reports)
    assert_equal [comments(:comment_11)], result
  end

  test 'returns all comments when document_type is not specified' do
    result = Searcher.search('コメント')
    assert_includes(result, comments(:comment_8))
    assert_includes(result, comments(:comment_10))
    assert_includes(result, comments(:comment_11))
    assert_includes(result, comments(:comment_12))
    assert_includes(result, comments(:comment_13))
    assert_includes(result, comments(:comment_14))
    assert_equal(6, result.size)
  end

  test 'returns only kimuras report when user param' do
    result = Searcher.search('ユーザーネームで検索できるよ user:daimyo')
    assert_includes(result, reports(:report_24))
    assert_not_includes(result, reports(:report_25))
  end
end
