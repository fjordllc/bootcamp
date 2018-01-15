module MetaTagsHelper
  def default_meta_tags
    {
      site: "FJORD BOOT CAMP（フィヨルドブートキャンプ）",
      reverse: true,
      charset: "utf-8",
      description: "無料でプログラミングスキルを身につけられるプログラマー就職支援サービス。スキルを身につけるための学習支援と、就職支援を行います。",
      viewport: "width=device-width, initial-scale=1.0",
      og: {
        title: :title,
        type: "website",
        site_name: "256interns",
        description: :description,
        image: "https://256interns.com/ogp/ogp.png",
        url: "https://256interns.com",
      },
      twitter: {
        card: "summary",
        site: "@256interns",
        description: :description,
        image: "https://256interns.com/ogp/ogp.png",
        domain: "https://256interns.com",
      }
    }
  end
end
