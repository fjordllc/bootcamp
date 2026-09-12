# frozen_string_literal: true

# ユーザーの所属(企業・受講コース)に関する責務をまとめたもの。
module UserAffiliation
  extend ActiveSupport::Concern

  included do
    belongs_to :company, optional: true
    belongs_to :course
  end
end
