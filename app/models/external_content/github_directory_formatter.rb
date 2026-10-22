# frozen_string_literal: true

class ExternalContent::GithubDirectoryFormatter
  FILES_LIMIT = ExternalContent::GithubReader::FILES_LIMIT

  def initialize(owner:, repository:, ref:, path:, items:)
    @owner = owner
    @repository = repository
    @ref = ref
    @path = path
    @items = items
  end

  def format
    lines = ['# GitHub Directory', "- repository: #{owner}/#{repository}", "- ref: #{ref}", "- path: /#{path}", '', '## entries']
    lines.concat(items.first(FILES_LIMIT).map { |item| "- #{item['type']}: #{item['path']} #{item['html_url']}" })
    lines << "- ...ほか #{items.size - FILES_LIMIT} 件" if items.size > FILES_LIMIT
    lines.join("\n")
  end

  private

  attr_reader :owner, :repository, :ref, :path, :items
end
