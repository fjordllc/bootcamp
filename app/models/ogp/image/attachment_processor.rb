# frozen_string_literal: true

module Ogp
  module Image
    module AttachmentProcessor
      extend Ogp::Image

      def self.fit_to_size(attached_one)
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
    end
  end
end
