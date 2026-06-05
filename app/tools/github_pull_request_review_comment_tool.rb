# frozen_string_literal: true

require 'net/http'
require 'uri'

class GithubPullRequestReviewCommentTool < RubyLLM::Tool
  description 'GitHub Pull Requestの特定ファイル・行にレビューコメントを投稿する。提出物にPRリンクがあり、コード行に紐づく具体的な指摘がある場合に使う。'

  param :pull_request_url, desc: 'コメント対象のGitHub Pull Request URL'
  param :path, desc: 'コメント対象ファイルのパス'
  param :line, type: :integer, desc: 'コメント対象行番号'
  param :body, desc: '提出者本人に向けたレビューコメント本文'
  param :side, type: :string, desc: 'コメント対象のdiff側。通常はRIGHT。削除行にコメントする場合のみLEFT', required: false

  def execute(pull_request_url:, path:, line:, body:, side: 'RIGHT')
    return 'PJORD_GITHUB_TOKENが設定されていないため、PRへのコメント投稿はできません。' if github_token.blank?
    return 'コメント本文が空のため、PRへのコメント投稿はできません。' if body.blank?

    owner, repository, pull_number = parse_pull_request_url(pull_request_url)
    return 'GitHub Pull Request URLの形式が正しくありません。' unless owner && repository && pull_number

    pull_request = get_json(api_url("/repos/#{owner}/#{repository}/pulls/#{pull_number}"))
    commit_id = pull_request.dig('head', 'sha')
    return 'Pull Requestを取得できませんでした。' if commit_id.blank?

    response = post_json(
      api_url("/repos/#{owner}/#{repository}/pulls/#{pull_number}/comments"),
      commit_id:,
      path:,
      line:,
      side: valid_side(side),
      body:
    )

    return "PRにレビューコメントを投稿しました: #{response['html_url']}" if response['html_url'].present?

    'PRへのコメント投稿に失敗しました。'
  rescue StandardError => e
    Rails.logger.warn("[GithubPullRequestReviewCommentTool] #{e.class}: #{e.message}")
    'PRへのコメント投稿に失敗しました。'
  end

  private

  def parse_pull_request_url(url)
    uri = URI.parse(url.to_s)
    return unless uri.is_a?(URI::HTTPS) && uri.host == 'github.com'

    match = uri.path.match(%r{\A/([^/]+)/([^/]+)/pull/(\d+)\z})
    match&.captures
  rescue URI::InvalidURIError
    nil
  end

  def get_json(url)
    response = request(Net::HTTP::Get.new(URI.parse(url)))
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end

  def post_json(url, payload)
    http_request = Net::HTTP::Post.new(URI.parse(url))
    http_request.body = payload.to_json
    response = request(http_request)
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end

  def request(http_request)
    uri = http_request.uri
    http_request['User-Agent'] = 'fjord-bootcamp-pjord'
    http_request['Accept'] = 'application/vnd.github+json'
    http_request['X-GitHub-Api-Version'] = '2022-11-28'
    http_request['Authorization'] = "Bearer #{github_token}"
    http_request['Content-Type'] = 'application/json' if http_request.is_a?(Net::HTTP::Post)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(http_request)
    end
  end

  def api_url(path)
    "https://api.github.com#{path}"
  end

  def valid_side(side)
    %w[LEFT RIGHT].include?(side) ? side : 'RIGHT'
  end

  def github_token
    ENV['PJORD_GITHUB_TOKEN'].presence
  end
end
