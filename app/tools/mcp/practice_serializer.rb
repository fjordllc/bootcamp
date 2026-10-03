# frozen_string_literal: true

module Mcp
  class PracticeSerializer
    def self.list_item(practice, canonical_origin:)
      {
        'id' => practice.id,
        'title' => practice.title,
        'summary' => practice.summary,
        'url' => practice_url(practice, canonical_origin:)
      }
    end

    def self.detail(practice, user:, canonical_origin:)
      result = {
        'id' => practice.id,
        'title' => practice.title,
        'summary' => practice.summary,
        'description' => practice.description,
        'goal' => practice.goal,
        'updated_at' => practice.updated_at&.iso8601,
        'url' => practice_url(practice, canonical_origin:)
      }
      result['memo'] = practice.memo if PracticePolicy.new(user, practice).show_memo?
      result
    end

    def self.practice_url(practice, canonical_origin:)
      "#{canonical_origin.delete_suffix('/')}/practices/#{practice.id}"
    end
    private_class_method :practice_url
  end
end
