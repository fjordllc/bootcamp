# frozen_string_literal: true

module UserValidations2
  extend ActiveSupport::Concern

  included do
    enum :editor, {
      vscode: 0,
      ruby_mine: 1,
      vim: 2,
      emacs: 3,
      other_editor: 99
    }, prefix: true

    enum :satisfaction, {
      excellent: 0,
      good: 1,
      average: 2,
      poor: 3,
      very_poor: 4
    }, prefix: true
  end
end
