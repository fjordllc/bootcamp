# frozen_string_literal: true

# ユーザーの所属(企業・受講コース)に関する責務をまとめたもの。
module UserAffiliation
  extend ActiveSupport::Concern

  included do
    belongs_to :company, optional: true
    belongs_to :course

    with_options if: -> { trainee? } do
      validates :company_id, presence: true
    end
  end
end
