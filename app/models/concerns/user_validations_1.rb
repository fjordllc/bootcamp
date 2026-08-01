# frozen_string_literal: true

module UserValidations1
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
  end
end
