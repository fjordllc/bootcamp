# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: "FJORD BOOT CAMP（フィヨルドブートキャンプ）",
      reverse: true,
      charset: "utf-8",
      description: "プログラミングスキルを身につけられるプログラマー就職支援サービス。スキルを身につけるための学習支援と、就職支援を行います。",
      viewport: "width=device-width, initial-scale=1.0",
      og: {
        title: :title,
        type: "website",
        site_name: "fjord bootcamp",
        description: :description,
        image: "https://bootcamp.fjord.jp/ogp/ogp.png",
        url: "https://bootcamp.fjord.jp",
      },
      twitter: {
        card: "summary",
        site: "@fjordbootcamp",
        description: :description,
        image: "https://bootcamp.fjord.jp/ogp/ogp.png",
        domain: "https://bootcamp.fjord.jp",
      }
    }
  end
end
