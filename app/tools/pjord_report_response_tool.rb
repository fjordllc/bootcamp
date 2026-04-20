# frozen_string_literal: true

class PjordReportResponseTool < RubyLLM::Tool
  description '日報への応答を確定する。' \
              'このツールを必ず最後に1回だけ呼ぶこと。' \
              '質問や困っている内容があり、アドバイスする場合は action="post" を指定し、advice にアドバイス本文を渡す。' \
              '質問や困っている内容がない場合は action="skip" を指定する（adviceは不要）。'

  param :action,
        type: :string,
        desc: '"post"（アドバイスを投稿する）または "skip"（質問なしのため投稿しない）'
  param :advice,
        type: :string,
        desc: 'action="post"のときのアドバイス本文（markdown形式、生徒宛）。skipのときは不要',
        required: false

  attr_reader :action, :advice

  def execute(action:, advice: nil)
    @action = action
    @advice = advice
    'OK'
  end

  def post?
    action == 'post' && advice.present?
  end
end
