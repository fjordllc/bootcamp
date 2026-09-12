# frozen_string_literal: true

# ユーザーの開発環境(OS・エディタ)に関する責務をまとめたもの。
module UserDevelopmentEnvironment
  extend ActiveSupport::Concern

  included do
    enum :os, { mac: 0, mac_apple: 2, linux: 1, windows_wsl2: 3 }, prefix: true
    enum :editor, { vscode: 0, ruby_mine: 1, vim: 2, emacs: 3, other_editor: 99 }, prefix: true

    validates :other_editor, presence: true, if: -> { editor == 'other_editor' }
  end
end
