# frozen_string_literal: true

class OgpCreator
  require 'mini_magick'

  BASE_IMAGE_PATH = './app/assets/images/ogp.jpg' # 仮画像 https://unsplash.com/photos/1_CMoFsPfso
  GRAVITY = 'center'
  TEXT_POSITION = '0,0'
  FONT = './app/assets/fonts/NotoSansJP-Regular.otf' # 仮フォント https://fonts.google.com/specimen/Noto+Sans+JP
  FONT_SIZE = 300
  INDENTION_COUNT = 16 # 1行の最大文字数
  ROW_LIMIT = 8

  def self.build(text)
    text = prepare_text(text)
    image = MiniMagick::Image.open(BASE_IMAGE_PATH)
    image.combine_options do |config|
      config.fill 'white'
      config.gravity GRAVITY
      config.font FONT
      config.pointsize FONT_SIZE
      config.draw "text #{TEXT_POSITION} '#{text}'"
    end
  end

  private

  def self.prepare_text(text)
    text.to_s.scan(/.{1,#{INDENTION_COUNT}}/)[0...ROW_LIMIT].join("\n")
  end
end
