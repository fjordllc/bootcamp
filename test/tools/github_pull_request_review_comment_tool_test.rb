# frozen_string_literal: true

require 'test_helper'
require 'supports/mock_env_helper'

class GithubPullRequestReviewCommentToolTest < ActiveSupport::TestCase
  include MockEnvHelper

  setup do
    @tool = GithubPullRequestReviewCommentTool.new
  end

  test 'posts a review comment to a pull request line' do
    mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
      stub_request(:get, 'https://api.github.com/repos/fjordllc/bootcamp/pulls/123')
        .with(headers: { 'Authorization' => 'Bearer token-for-pjord' })
        .to_return(
          status: 200,
          body: { head: { sha: 'abc123' } }.deep_stringify_keys.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:post, 'https://api.github.com/repos/fjordllc/bootcamp/pulls/123/comments')
        .with(
          headers: { 'Authorization' => 'Bearer token-for-pjord' },
          body: {
            commit_id: 'abc123',
            path: 'app/models/product.rb',
            line: 42,
            side: 'RIGHT',
            body: 'この条件はモデル側に寄せると読みやすくなりそうです。'
          }.to_json
        )
        .to_return(
          status: 201,
          body: { html_url: 'https://github.com/fjordllc/bootcamp/pull/123#discussion_r1' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = @tool.execute(
        pull_request_url: 'https://github.com/fjordllc/bootcamp/pull/123',
        path: 'app/models/product.rb',
        line: 42,
        body: 'この条件はモデル側に寄せると読みやすくなりそうです。'
      )

      assert_equal 'PRにレビューコメントを投稿しました: https://github.com/fjordllc/bootcamp/pull/123#discussion_r1', result
    end
  end

  test 'does not post without Pjord GitHub token' do
    mock_env('PJORD_GITHUB_TOKEN' => nil) do
      result = @tool.execute(
        pull_request_url: 'https://github.com/fjordllc/bootcamp/pull/123',
        path: 'app/models/product.rb',
        line: 42,
        body: 'コメント'
      )

      assert_equal 'PJORD_GITHUB_TOKENが設定されていないため、PRへのコメント投稿はできません。', result
    end
  end

  test 'rejects non pull request urls' do
    mock_env('PJORD_GITHUB_TOKEN' => 'token-for-pjord') do
      result = @tool.execute(
        pull_request_url: 'https://github.com/fjordllc/bootcamp/issues/123',
        path: 'app/models/product.rb',
        line: 42,
        body: 'コメント'
      )

      assert_equal 'GitHub Pull Request URLの形式が正しくありません。', result
    end
  end
end
