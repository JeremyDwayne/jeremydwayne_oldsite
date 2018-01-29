#encoding: UTF-8

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "JeremyDwayne"
    xml.author "Jeremy Winterberg"
    xml.description "Coffee. Code. Repeat."
    xml.link "https://www.jeremydwayne.com"
    xml.language "en"

    for article in @blog_articles
      xml.item do
        if article.title
          xml.title article.title
        else
          xml.title ""
        end
        xml.author "Jeremy Winterberg"
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link "https://www.jeremydwayne.com/blog/" + article.slug
        xml.guid article.id

        text = article.content
        xml.description "<p>" + text + "</p>"

      end
    end
  end
end
