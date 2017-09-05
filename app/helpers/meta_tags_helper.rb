module MetaTagsHelper
  def default_meta_tags
    {
      site: "256 INTERNS",
      reverse: true,
      charset: "utf-8",
      description: "Eラーニングサービス。",
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
