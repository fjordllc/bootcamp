# frozen_string_literal: true

module UserJobAndEnvironmentEnums
  extend ActiveSupport::Concern

  included do
    enum :job, {
      student: 0,
      office_worker: 2,
      part_time_worker: 3,
      vacation: 4,
      unemployed: 5
    }, prefix: true

    enum :os, {
      mac: 0,
      mac_apple: 2,
      linux: 1,
      windows_wsl2: 3
    }, prefix: true

    enum :editor, {
      vscode: 0,
      ruby_mine: 1,
      vim: 2,
      emacs: 3,
      other_editor: 99
    }, prefix: true
  end
end
