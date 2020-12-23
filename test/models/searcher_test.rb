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
    assert_equal [reports(:report14), reports(:report13), reports(:report12)], result
    assert_not_includes(result, Answer)
  end

  test 'returns only reports having all keywords' do
    result = Searcher.search('日報', document_type: :reports)
    assert_includes(result, reports(:report9))
    assert_includes(result, reports(:report8))

    result = Searcher.search('日報 WIP', document_type: :reports)
    assert_includes(result, reports(:report9))
    assert_not_includes(result, reports(:report8))

    result = Searcher.search('日報　WIP', document_type: :reports)
    assert_includes(result, reports(:report9))
    assert_not_includes(result, reports(:report8))
  end

  test 'returns only pages having all keywords' do
    result = Searcher.search('テスト', document_type: :pages)
    assert_includes(result, pages(:page4))
    assert_includes(result, pages(:page3))

    result = Searcher.search('テスト Bootcamp', document_type: :pages)
    assert_includes(result, pages(:page4))
    assert_not_includes(result, pages(:page3))

    result = Searcher.search('テスト　Bootcamp', document_type: :pages)
    assert_includes(result, pages(:page4))
    assert_not_includes(result, pages(:page3))
  end

  test 'returns only practices having all keywords' do
    result = Searcher.search('OS', document_type: :practices)
    assert_includes(result, practices(:practice1))
    assert_includes(result, practices(:practice3))

    result = Searcher.search('OS クリーンインストール', document_type: :practices)
    assert_includes(result, practices(:practice1))
    assert_not_includes(result, practices(:practice3))

    result = Searcher.search('OS　クリーンインストール', document_type: :practices)
    assert_includes(result, practices(:practice1))
    assert_not_includes(result, practices(:practice3))
  end

  test 'returns only questions having all keywords' do
    result = Searcher.search('使う', document_type: :questions)
    assert_includes(result, questions(:question2))
    assert_includes(result, questions(:question1))

    result = Searcher.search('使う エディター', document_type: :questions)
    assert_includes(result, questions(:question1))
    assert_not_includes(result, questions(:question2))

    result = Searcher.search('使う　エディター', document_type: :questions)
    assert_includes(result, questions(:question1))
    assert_not_includes(result, questions(:question2))
  end

  test 'returns only answers of questions having all keywords' do
    result = Searcher.search('です', document_type: :questions)
    assert_includes(result, answers(:answer1))
    assert_includes(result, answers(:answer5))

    result = Searcher.search('です atom', document_type: :questions)
    assert_includes(result, answers(:answer1))
    assert_not_includes(result, answers(:answer5))

    result = Searcher.search('です　atom', document_type: :questions)
    assert_includes(result, answers(:answer1))
    assert_not_includes(result, answers(:answer5))
  end

  test 'returns only announcements having all keywords' do
    result = Searcher.search('お知らせ', document_type: :announcements)
    assert_includes(result, announcements(:announcement3))
    assert_includes(result, announcements(:announcement_notification_active_user))

    result = Searcher.search('お知らせ 通知', document_type: :announcements)
    assert_includes(result, announcements(:announcement_notification_active_user))
    assert_not_includes(result, announcements(:announcement3))

    result = Searcher.search('お知らせ　通知', document_type: :announcements)
    assert_includes(result, announcements(:announcement_notification_active_user))
    assert_not_includes(result, announcements(:announcement3))
  end

  test 'returns only comments having all keywords' do
    result = Searcher.search('report_id', document_type: :reports)
    assert_includes(result, comments(:comment6))
    assert_includes(result, comments(:comment5))

    result = Searcher.search('report_id typo', document_type: :reports)
    assert_includes(result, comments(:comment6))
    assert_not_includes(result, comments(:comment5))

    result = Searcher.search('report_id　typo', document_type: :reports)
    assert_includes(result, comments(:comment6))
    assert_not_includes(result, comments(:comment5))
  end

  test 'returns only comments associated to specified document_type' do
    result = Searcher.search('コメント', document_type: :reports)
    assert_equal [comments(:comment11)], result
  end

  test 'returns all comments when document_type is not specified' do
    result = Searcher.search('コメント')
    assert_includes(result, comments(:comment8))
    assert_includes(result, comments(:comment10))
    assert_includes(result, comments(:comment11))
    assert_includes(result, comments(:comment12))
    assert_includes(result, comments(:comment13))
    assert_includes(result, comments(:comment14))
    assert_equal(6, result.size)
  end

  test 'returns only daimyos report when user param' do
    result = Searcher.search('ユーザーネームで検索できるよ user:daimyo')
    assert_includes(result, reports(:report24))
    assert_not_includes(result, reports(:report25))
  end

  test 'returns only updated-by-komagata practice when user param' do
    result = Searcher.search('ユーザーネーム（最終更新者）で検索できるよ user:komagata')
    assert_includes(result, practices(:practice55))
    assert_not_includes(result, practices(:practice56))
  end
end
