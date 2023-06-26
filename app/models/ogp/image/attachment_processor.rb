# frozen_string_literal: true

module Ogp
  module Image
    class AttachmentProcessor
      WIDTH = 1200
      HEIGHT = 630

      class << self
        def fit_to_size(attached_one)
          blob = attached_one.blob
          blob.analyze unless blob.analyzed?
          width = blob.metadata[:width]
          height = blob.metadata[:height]

          return nil if just_fit_to_size?(width: width, height: height)

          opts = fit_to_size_option(width: width, height: height)

          fitted = attached_one.variant(**opts).processed.image.blob

          # 変形前の画像関連データの削除にpurge、purge_laterは不要。
          # データの削除はattachで担える
          attached_one.attach(fitted)
        end

        def just_fit_to_size?(width:, height:)
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
  end
end
