atom_feed(language: 'ja-JP') do |feed|
  feed.title 'みんなのブログ'
  feed.updated @entries.first.published
  @entries.each do |article|
    if article.updated
      feed.entry(
        article,
        url:       article.url,
        id:        article.url,
        published: article.published,
        updated:   article.updated
      ) do |item|
        item.title article.title

        if article.content.nil?
          item.content(article.summary, type: 'html')
        else
          item.content(article.content, type: 'html')
        end

        if article.author
          item.author do |author|
            author.name article.author
          end
        end
      end
    else
      feed.entry(
        article,
        url:       article.url,
        id:        article.url,
        published: article.published,
        updated:   article.published
      ) do |item|
        item.title article.title

        if article.content.nil?
          item.content(article.summary, type: 'html')
        else
          item.content(article.content, type: 'html')
        end

        if article.author
          item.author do |author|
            author.name article.author
          end
        end
      end
    end
  end
end
