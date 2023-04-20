# frozen_string_literal: true

module Ogp
  module Image
    WIDTH = 1200
    HEIGHT = 630

    def fit?(width:, height:)
      width == WIDTH && height == HEIGHT
    end

    def fit_to_size_option(width:, height:)
      # ハッシュを返すが処理順(リサイズ->切り抜き)にオプションを記述
      {}.merge(resize_option(width: width, height: height), clip_option)
    end

    def resize_option(width:, height:)
      ratio_w = WIDTH.to_f / width
      ratio_h = HEIGHT.to_f / height

      if ratio_w > ratio_h
        { resize: "#{WIDTH}x" }
      else
        { resize: "x#{HEIGHT}" }
      end
    end

    def clip_option
      { gravity: :center,
        # 仮想キャンバスのメタデータをリセットするために!を末尾につける
        # +repageは指定できないため、+repage相当の動作をする!を採用
        crop: "#{WIDTH}x#{HEIGHT}+0+0!" }
    end
  end
end
