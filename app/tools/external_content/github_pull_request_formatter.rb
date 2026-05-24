# frozen_string_literal: true

class ExternalContent::GithubPullRequestFormatter
  FILES_LIMIT = ExternalContent::GithubReader::FILES_LIMIT

  def initialize(owner:, repository:, url:, pull_request:, files:)
    @owner = owner
    @repository = repository
    @url = url
    @pull_request = pull_request
    @files = files
  end

  def format
    lines = header_lines
    lines.concat(files.first(FILES_LIMIT).map { |file| file_line(file) })
    lines << "- ...ほか #{files.size - FILES_LIMIT} ファイル" if files.size > FILES_LIMIT
    lines << ''
    lines << '必要なら、上記の raw URL をこのツールに渡してファイル全体を確認してください。'
    lines.join("\n")
  end

  private

  attr_reader :owner, :repository, :url, :pull_request, :files

  def header_lines
    [
      '# GitHub Pull Request',
      "- URL: #{url}",
      "- タイトル: #{pull_request['title']}",
      "- ブランチ: #{pull_request.dig('head', 'ref')}",
      "- ベースブランチ: #{pull_request.dig('base', 'ref')}",
      "- head SHA: #{head_sha}",
      '',
      '## 説明',
      normalize_body(pull_request['body']).presence || 'なし',
      '',
      '## 変更ファイル'
    ]
  end

  def file_line(file)
    patch = normalize_body(file['patch']).slice(0, 1_500)
    line = "- #{file['filename']} (#{file['status']}, +#{file['additions']} -#{file['deletions']})"
    line += "\n  raw URL: #{raw_url(file['filename'])}" if head_sha.present?
    line += "\n  patch:\n#{indent(patch.presence || 'patchなし')}"
    line
  end

  def raw_url(path)
    "https://raw.githubusercontent.com/#{owner}/#{repository}/#{head_sha}/#{path}"
  end

  def head_sha
    @head_sha ||= pull_request.dig('head', 'sha')
  end

  def normalize_body(body)
    body.to_s.dup.force_encoding(Encoding::UTF_8).scrub
  end

  def indent(text)
    text.to_s.lines.map { |line| "  #{line}" }.join
  end
end
