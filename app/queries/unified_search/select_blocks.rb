# frozen_string_literal: true

module UnifiedSearch
  module SelectBlocks
    private

    def select_for_announcements
      select_block('announcements', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, UnifiedSearch::Builder::FALLBACK_BODY_CANDIDATES)
    end

    def select_for_practices
      select_block('practices', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, %w[description body],
                   user_id_sql: user_id_expr('practices', prefer_last_updated: true))
    end

    def select_for_reports
      select_block('reports', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, %w[description body])
    end

    def select_for_products
      products_block
    end

    def select_for_questions
      [select_block('questions', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, UnifiedSearch::Builder::FALLBACK_BODY_CANDIDATES),
       questions_block].join("\nUNION ALL\n")
    end

    def select_for_pages
      select_block('pages', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, UnifiedSearch::Builder::FALLBACK_BODY_CANDIDATES)
    end

    def select_for_events
      select_block('events', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, UnifiedSearch::Builder::FALLBACK_BODY_CANDIDATES)
    end

    def select_for_regular_events
      select_block('regular_events', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES, UnifiedSearch::Builder::FALLBACK_BODY_CANDIDATES)
    end

    def select_for_comments
      comments_block
    end

    def select_for_users
      users_block
    end
  end
end
