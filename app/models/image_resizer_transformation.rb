# frozen_string_literal: true

class ImageResizerTransformation
  def fit_to(original_width, original_height, width, height)
    # ハッシュを返すが処理順(リサイズ->切り抜き)にオプションを記述
    {}.merge(resize(original_width, original_height, width, height),
             center_crop(width, height))
  end

  # 縦横比を維持しながら、リサイズ後の縦をx、横をyとしたときに
  # いずれかの条件を満たすようにリサイズする
  # x = widht かつ y >= height
  # x >= width かつ y = height
  def resize(original_width, original_height, width, height)
    ratio_w = width.to_f / original_width
    ratio_h = height.to_f / original_height

    if ratio_w > ratio_h
      { resize: "#{width}x" }
    else
      { resize: "x#{height}" }
    end
  end

  def center_crop(width, height)
    { gravity: :center,
      # 仮想キャンバスのメタデータをリセットするために!を末尾につける
      # +repageは指定できないため、+repage相当の動作をする!を採用
      crop: "#{width}x#{height}+0+0!" }
  end
end
