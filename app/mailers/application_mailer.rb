# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "フィヨルドブートキャンプ <info@fjord.jp>"
  layout "mailer"
end
